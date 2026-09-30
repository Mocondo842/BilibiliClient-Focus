import Foundation
#if canImport(Darwin)
import Darwin
#endif

/// CDN 请求所需的三件套。引擎不直接读全局单例，凭据由调用方注入。
struct DownloadCredentials: Sendable {
    var cookieHeader: String
    var referer: String
    var userAgent: String

    /// 取应用当前的登录态。没有登录也能下（只能下到 480P 及以下）。
    static var current: DownloadCredentials {
        DownloadCredentials(
            cookieHeader: APIClient.shared.cookieHeader,
            referer: APIConstants.referer,
            userAgent: APIConstants.userAgent
        )
    }
}

/// 带 Referer / Cookie / Range 的分块传输层。
///
/// 职责被刻意收窄成「把字节搬到文件的正确偏移上」：
/// 它不认识清晰度、不认识合流，只认地址和区间。
/// 上层要的进度、限速、重试、备用地址轮换都在这里完成。
final class ByteRangeTransport: @unchecked Sendable {

    /// 探测结果。
    struct ResourceInfo: Sendable {
        /// 资源总字节数，未知为 nil。
        let totalSize: Int64?
        /// 是否值得尝试分块下载。
        let supportsRanges: Bool
    }

    private let session: URLSession
    private let credentials: DownloadCredentials
    private let options: DownloadOptions

    init(credentials: DownloadCredentials, options: DownloadOptions) {
        self.credentials = credentials
        self.options = options

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = options.requestTimeout
        // 单个分块的传输不该被整体超时打断
        configuration.timeoutIntervalForResource = 60 * 60
        configuration.httpMaximumConnectionsPerHost = max(4, options.concurrency)
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - 探测

    /// 探测资源体积。先试 HEAD（不产生响应体），失败再退回带 Range 的 GET。
    func probe(_ urls: [URL]) async throws -> ResourceInfo {
        var lastError: Error?
        for url in urls {
            do {
                return try await headProbe(url)
            } catch {
                lastError = error
            }
        }
        for url in urls {
            do {
                return try await rangedProbe(url)
            } catch {
                lastError = error
            }
        }
        throw lastError ?? DownloadError.unknownResourceSize
    }

    private func headProbe(_ url: URL) async throws -> ResourceInfo {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        applyCommonHeaders(to: &request)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw DownloadError.http(-1) }
        guard (200..<300).contains(http.statusCode) else { throw DownloadError.http(http.statusCode) }

        let length = http.value(forHTTPHeaderField: "Content-Length").flatMap(Int64.init)
        let rangeHeader = http.value(forHTTPHeaderField: "Accept-Ranges")?.lowercased()
        // 显式声明不支持 Range 时就不必再试分块；没写这个头则保持乐观，
        // 真正的判定放在第一次分块请求上（拿到 200 就回退顺序下载）。
        let explicitlyUnitRangeable = rangeHeader != nil && rangeHeader?.contains("bytes") == false
        return ResourceInfo(totalSize: length, supportsRanges: length != nil && !explicitlyUnitRangeable)
    }

    private func rangedProbe(_ url: URL) async throws -> ResourceInfo {
        var request = URLRequest(url: url)
        request.setValue("bytes=0-0", forHTTPHeaderField: "Range")
        applyCommonHeaders(to: &request)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw DownloadError.http(-1) }
        guard (200..<300).contains(http.statusCode) else { throw DownloadError.http(http.statusCode) }

        if http.statusCode == 206, let total = Self.totalSize(fromContentRange: http) {
            return ResourceInfo(totalSize: total, supportsRanges: true)
        }
        let length = http.value(forHTTPHeaderField: "Content-Length").flatMap(Int64.init)
        return ResourceInfo(totalSize: length, supportsRanges: false)
    }

    /// 从 `Content-Range: bytes 0-0/123456` 里取出总长度。
    private static func totalSize(fromContentRange response: HTTPURLResponse) -> Int64? {
        guard let value = response.value(forHTTPHeaderField: "Content-Range"),
              let slash = value.lastIndex(of: "/") else { return nil }
        let tail = value[value.index(after: slash)...].trimmingCharacters(in: .whitespaces)
        guard tail != "*" else { return nil }
        return Int64(tail)
    }

    // MARK: - 分块并发下载

    /// 把 `urls` 指向的资源并发分块下载到 `destination`。
    ///
    /// - Parameters:
    ///   - totalSize: 已知的资源总字节数，文件会预先按这个长度落盘。
    ///   - onBytes: 累计已接收字节的回调，可能被多个 worker 并发触发（内部已做节流）。
    func download(urls: [URL],
                  to destination: URL,
                  totalSize: Int64,
                  onBytes: @Sendable @escaping (Int64) -> Void) async throws {
        let descriptor = Darwin.open(destination.path, O_WRONLY | O_CREAT | O_TRUNC, 0o644)
        guard descriptor >= 0 else {
            throw DownloadError.writeFailed(String(cString: strerror(errno)))
        }
        defer { close(descriptor) }

        guard ftruncate(descriptor, off_t(totalSize)) == 0 else {
            throw DownloadError.writeFailed(String(cString: strerror(errno)))
        }

        let counter = ByteCounter(onUpdate: onBytes)
        let limiter = options.speedLimit.map { SpeedLimiter(limit: $0) }
        let chunks = Self.makeChunks(totalSize: totalSize,
                                     chunkSize: options.chunkSize,
                                     desiredCount: options.concurrency)
        guard !chunks.isEmpty else { return }

        try await withThrowingTaskGroup(of: Void.self) { group in
            var next = 0
            let inFlight = min(options.concurrency, chunks.count)

            while next < inFlight {
                let chunk = chunks[next]
                next += 1
                group.addTask { [self] in
                    try await fetch(chunk, urls: urls, descriptor: descriptor, counter: counter, limiter: limiter)
                }
            }
            // 每完成一块就补一块，保持固定并发度
            while let _ = try await group.next() {
                guard next < chunks.count else { continue }
                let chunk = chunks[next]
                next += 1
                group.addTask { [self] in
                    try await fetch(chunk, urls: urls, descriptor: descriptor, counter: counter, limiter: limiter)
                }
            }
        }
    }

    /// 顺序下载（服务器不支持 Range 时的兜底）。交给 URLSession 直接落盘，不进内存。
    func downloadSequentially(urls: [URL], to destination: URL) async throws {
        var lastError: Error?
        for url in urls {
            do {
                var request = URLRequest(url: url)
                applyCommonHeaders(to: &request)
                let (temporaryURL, response) = try await session.download(for: request)
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                guard (200..<300).contains(status) else { throw DownloadError.http(status) }
                try? FileManager.default.removeItem(at: destination)
                try FileManager.default.moveItem(at: temporaryURL, to: destination)
                return
            } catch {
                lastError = error
            }
        }
        throw lastError ?? DownloadError.unknownResourceSize
    }

    // MARK: - 单块传输

    private func fetch(_ chunk: Chunk,
                       urls: [URL],
                       descriptor: Int32,
                       counter: ByteCounter,
                       limiter: SpeedLimiter?) async throws {
        guard !urls.isEmpty else { throw DownloadError.unknownResourceSize }

        var attempt = 0
        var cursor = chunk.start

        while cursor <= chunk.end {
            try Task.checkCancellation()
            // 备用地址轮换：第 n 次重试就换第 n 个地址
            let url = urls[attempt % urls.count]
            do {
                let (data, response) = try await requestBytes(from: url, range: "\(cursor)-\(chunk.end)")

                // 只有首个字节就在 0 位置时，200 才是合法的（服务器忽略了 Range）
                guard response.statusCode == 206 || (response.statusCode == 200 && cursor == 0) else {
                    throw DownloadError.rangeUnsupported
                }
                guard !data.isEmpty else {
                    // 空响应：已经在区间之外说明本来就没有更多数据了
                    if cursor > chunk.end { return }
                    throw DownloadError.http(response.statusCode)
                }

                try Self.write(descriptor: descriptor, data: data, offset: cursor)
                cursor += Int64(data.count)
                counter.add(Int64(data.count))
                if let limiter { await limiter.consume(Int64(data.count)) }
                attempt = 0
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                if Self.isFatal(error) { throw error }
                attempt += 1
                guard attempt <= options.maxRetries else { throw error }
                let delay = options.retryBackoff * pow(2, Double(attempt - 1))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    private func requestBytes(from url: URL, range: String?) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        applyCommonHeaders(to: &request)
        if let range {
            request.setValue("bytes=\(range)", forHTTPHeaderField: "Range")
        }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw DownloadError.http(-1) }
        guard (200..<300).contains(http.statusCode) else { throw DownloadError.http(http.statusCode) }
        return (data, http)
    }

    private func applyCommonHeaders(to request: inout URLRequest) {
        request.setValue(credentials.referer, forHTTPHeaderField: "Referer")
        request.setValue(credentials.userAgent, forHTTPHeaderField: "User-Agent")
        if !credentials.cookieHeader.isEmpty {
            request.setValue(credentials.cookieHeader, forHTTPHeaderField: "Cookie")
        }
    }

    /// 重试也救不回来的错误，直接往上抛。
    private static func isFatal(_ error: Error) -> Bool {
        guard let downloadError = error as? DownloadError else { return false }
        switch downloadError {
        case .rangeUnsupported, .writeFailed, .insufficientSpace:
            return true
        default:
            return false
        }
    }

    // MARK: - 写入

    private struct Chunk: Sendable {
        let start: Int64
        let end: Int64
    }

    private static func makeChunks(totalSize: Int64, chunkSize: Int64, desiredCount: Int) -> [Chunk] {
        guard totalSize > 0, chunkSize > 0 else { return [] }

        // 小文件如果按固定分块切，会出现「整条流只有一块」的情况，
        // 那样并发度再高也只有一条连接在跑。这里按目标并发数反推分块大小，
        // 保证文件够大时至少能切出 desiredCount 块；下限 256 KB 避免请求碎片化。
        var effectiveSize = chunkSize
        if desiredCount > 1 {
            let ideal = totalSize / Int64(desiredCount)
            if ideal < effectiveSize {
                effectiveSize = max(ideal, 256 << 10)
            }
        }

        var chunks: [Chunk] = []
        var offset: Int64 = 0
        while offset < totalSize {
            let end = min(offset + effectiveSize, totalSize) - 1
            chunks.append(Chunk(start: offset, end: end))
            offset = end + 1
        }
        return chunks
    }

    /// 用 pwrite 写到指定偏移。不同偏移之间是线程安全的，所以多个 worker 可以共用同一个 fd。
    private static func write(descriptor: Int32, data: Data, offset: Int64) throws {
        try data.withUnsafeBytes { buffer in
            guard let base = buffer.baseAddress else { return }
            var written = 0
            while written < buffer.count {
                let result = pwrite(descriptor,
                                    base.advanced(by: written),
                                    buffer.count - written,
                                    off_t(offset) + off_t(written))
                if result < 0 {
                    throw DownloadError.writeFailed(String(cString: strerror(errno)))
                }
                if result == 0 {
                    throw DownloadError.writeFailed("磁盘写入返回 0 字节")
                }
                written += result
            }
        }
    }
}

// MARK: - 进度计数

/// 并发安全的字节计数与节流回调。
///
/// 8 个 worker 每 4 MB 就回调一次会把手 UI 刷爆，所以这里按 0.2 秒节流，
/// 节流窗口之外的那一次一定会在最后一次调用里补上。
private final class ByteCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var received: Int64 = 0
    private var lastEmit: TimeInterval = 0
    private let onUpdate: @Sendable (Int64) -> Void

    init(onUpdate: @escaping @Sendable (Int64) -> Void) {
        self.onUpdate = onUpdate
    }

    func add(_ delta: Int64) {
        lock.lock()
        received += delta
        let now = Date().timeIntervalSinceReferenceDate
        let shouldEmit = now - lastEmit >= 0.2
        if shouldEmit { lastEmit = now }
        let value = received
        lock.unlock()
        if shouldEmit { onUpdate(value) }
    }
}

// MARK: - 限速

/// 平均速率限速器：按「已发送字节 / 限额」算出应该花掉的时间，快了就补睡。
private final class SpeedLimiter: @unchecked Sendable {
    private let limit: Int64
    private let startedAt = Date()
    private let lock = NSLock()
    private var total: Int64 = 0

    init(limit: Int64) {
        self.limit = max(limit, 1)
    }

    func consume(_ bytes: Int64) async {
        let sent = record(bytes)

        let expected = Double(sent) / Double(limit)
        let actual = Date().timeIntervalSince(startedAt)
        let deficit = expected - actual
        if deficit > 0.02 {
            try? await Task.sleep(nanoseconds: UInt64(deficit * 1_000_000_000))
        }
    }

    /// 加锁的部分单独拆成同步方法：NSLock 不能在异步上下文里直接 lock/unlock。
    private func record(_ bytes: Int64) -> Int64 {
        lock.lock()
        defer { lock.unlock() }
        total += bytes
        return total
    }
}
