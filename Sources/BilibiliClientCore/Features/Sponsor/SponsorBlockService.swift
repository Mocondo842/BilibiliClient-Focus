import CryptoKit
import Foundation

/// SponsorBlock 兼容接口的客户端。
///
/// 接口形态（由上游 `hanydd/BilibiliSponsorBlock` 的 `src/config/serverConfig.ts`
/// 与 `src/requests/background/segmentRequest.ts` 确定，并已实测）：
///
/// ```
/// GET {server}/api/skipSegments/{hashPrefix}
/// hashPrefix = SHA256(bvid) 十六进制的前 4 位
/// ```
///
/// 这个「哈希前缀」设计是它相对原版 SponsorBlock 的隐私取舍：服务端只看到
/// 4 位十六进制（65536 个桶），**不会知道你在看哪个视频**；代价是一次会返回
/// 同前缀下的一批视频，需要客户端自己筛出目标那条。因此这里的流程是
/// 「算前缀 → 取回一批 → 本地按 bvid 过滤」。
///
/// 这是第三方社区服务（个人业余维护），所以整个客户端按「尽力而为」设计：
/// 失败一律降级成空结果并记日志，绝不让它影响播放主流程。
actor SponsorBlockService {

    static let shared = SponsorBlockService()

    /// 服务地址，按顺序尝试。
    private let servers = [
        "https://www.bsbsb.top",
        "https://www.bsbsb.xyz",
    ]

    /// 缓存有效期。片段数据变化很慢，30 分钟足够且能显著减少请求。
    private let cacheTTL: TimeInterval = 30 * 60

    private struct CacheEntry {
        let storedAt: Date
        let segments: [SponsorSegment]
    }

    private var cache: [String: CacheEntry] = [:]
    /// 同一个 bvid 的并发请求合并成一次
    private var inFlight: [String: Task<[SponsorSegment], Never>] = [:]

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 20
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }

    // MARK: - 对外

    /// 取某个视频的全部原始片段（**未按分类/设置过滤**，由调用方按当前设置筛）。
    ///
    /// 任何失败都返回空数组——空降助手挂掉不该让视频看不了。
    func segments(for bvid: String) async -> [SponsorSegment] {
        guard !bvid.isEmpty else { return [] }

        if let entry = cache[bvid], Date().timeIntervalSince(entry.storedAt) < cacheTTL {
            return entry.segments
        }
        if let running = inFlight[bvid] {
            return await running.value
        }

        let task = Task<[SponsorSegment], Never> { [servers, session] in
            let prefix = Self.hashPrefix(bvid)
            for server in servers {
                guard let url = URL(string: "\(server)/api/skipSegments/\(prefix)") else { continue }
                do {
                    let segments = try await Self.fetch(from: url, bvid: bvid, session: session)
                    AppLog.player.debug("空降助手：\(server) 返回 \(segments.count) 条片段 bvid=\(bvid) prefix=\(prefix)")
                    return segments
                } catch {
                    AppLog.player.debug("空降助手：\(server) 失败（\(error.localizedDescription)），尝试下一个地址")
                }
            }
            AppLog.player.debug("空降助手：所有地址都失败，bvid=\(bvid) 本次不做处理")
            return []
        }
        inFlight[bvid] = task
        let result = await task.value
        inFlight[bvid] = nil
        cache[bvid] = CacheEntry(storedAt: Date(), segments: result)
        return result
    }

    /// 清空缓存（设置变更或用户手动刷新时用）。
    func invalidate() {
        cache.removeAll()
    }

    // MARK: - 哈希

    /// `SHA256(bvid)` 的十六进制前 4 位。
    static func hashPrefix(_ bvid: String) -> String {
        let digest = SHA256.hash(data: Data(bvid.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return String(hex.prefix(4))
    }

    // MARK: - 请求与解析

    private static func fetch(from url: URL,
                              bvid: String,
                              session: URLSession) async throws -> [SponsorSegment] {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { return [] }
        // 404 = 这个前缀下没有任何片段，是正常情况而不是错误
        if http.statusCode == 404 { return [] }
        guard (200..<300).contains(http.statusCode) else { return [] }

        let entries = try JSONDecoder().decode([HashedEntry].self, from: data)
        // 同前缀下会有一批视频，只取属于这个 bvid 的
        let matched = entries.filter {
            $0.videoID == bvid || $0.videoID.hasPrefix(bvid + "+")
        }
        return matched.flatMap { $0.segments ?? [] }.compactMap(Self.makeSegment(from:))
    }

    /// 单条原始片段 → 领域模型。认不出来的分类/动作直接丢弃，不猜。
    private static func makeSegment(from raw: RawSegment) -> SponsorSegment? {
        guard let category = SponsorCategory(rawValue: raw.category),
              let action = SponsorAction(rawValue: raw.actionType),
              raw.segment.count >= 2 else { return nil }

        let start = raw.segment[0]
        let end = raw.segment[1]
        guard start.isFinite, end.isFinite, start >= 0 else { return nil }

        return SponsorSegment(
            id: raw.uuid ?? "\(raw.category)-\(start)-\(end)",
            category: category,
            action: action,
            start: start,
            end: max(end, start),
            // 服务端把 cid 当字符串传，这里宽进：字符串或数字都认
            cid: raw.cid.flatMap(Int.init),
            videoDuration: raw.videoDuration ?? 0,
            votes: raw.votes ?? 0,
            description: raw.description ?? ""
        )
    }

    // MARK: - 传输模型

    private struct HashedEntry: Decodable {
        let videoID: String
        let segments: [RawSegment]?
    }

    private struct RawSegment: Decodable {
        let cid: String?
        let category: String
        let actionType: String
        let segment: [Double]
        let uuid: String?
        let videoDuration: Double?
        let votes: Int?
        let description: String?

        // 接口本身就是 camelCase，只有 UUID 是全大写，所以不用 convertFromSnakeCase，
        // 全部显式声明，避免大小写策略带来的歧义。
        enum CodingKeys: String, CodingKey {
            case cid, category, actionType, segment, videoDuration, votes, description
            case uuid = "UUID"
        }
    }
}
