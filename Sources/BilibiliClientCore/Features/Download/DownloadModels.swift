import Foundation

// MARK: - 请求

/// 一次下载请求的描述。引擎只认这四项，不关心界面怎么拿到它们。
struct DownloadRequest: Sendable, Equatable {
    /// 视频 bvid。
    var bvid: String
    /// 要下载的分P cid。
    var cid: Int
    /// 视频标题（用于文件名与界面展示）。
    var title: String
    /// 分P 标题（多P 视频才有）。
    var pageTitle: String?
    /// 分P 序号，从 1 开始（多P 视频才有）。
    var pageIndex: Int?

    /// 出现在文件名里的显示名：多P 时带上分P 标题。
    var displayName: String {
        guard let pageTitle, !pageTitle.isEmpty, pageTitle != title else { return title }
        if let pageIndex { return "\(title) - P\(pageIndex) \(pageTitle)" }
        return "\(title) - \(pageTitle)"
    }
}

// MARK: - 清晰度

/// 一条「实际可下载」的清晰度。
///
/// 注意区分「服务器支持的清晰度」与「当前账号能拿到的清晰度」：
/// 后者才是能真正下下来的，所以这里只由 playurl 实际返回的流生成。
struct DownloadQuality: Identifiable, Hashable, Sendable {
    /// qn，B 站的清晰度编号。
    let id: Int
    /// 清晰度名称，如「1080P 高清」。
    let name: String
    /// 补充说明，如「1920×1080 · 60fps · AVC · 5.2 Mbps」。
    let detail: String
    /// 视频轨码率。
    let bandwidth: Int
    /// 视频轨容器体积（字节），未知为 nil。
    let estimatedSize: Int64?
    /// 该清晰度对应的编码前缀，用于界面提示。
    let codec: String?
}

// MARK: - 进度

/// 下载过程中的一次进度快照。
struct DownloadProgress: Sendable, Equatable {
    /// 当前所处阶段。
    enum Phase: Sendable, Equatable {
        /// 解析 playurl、探测资源体积。
        case preparing
        /// 正在拉取媒体分块。
        case downloading
        /// 正在把音视频合流。
        case muxing
        /// 已完成。
        case finished
    }

    var phase: Phase = .preparing
    /// 已接收字节。
    var bytesReceived: Int64 = 0
    /// 总字节，未知为 0。
    var bytesTotal: Int64 = 0
    /// 完成比例 0...1，总量未知时为 nil。
    var fraction: Double?
    /// 实时速度（字节/秒）。
    var bytesPerSecond: Double = 0
    /// 预计剩余秒数。
    var estimatedRemaining: TimeInterval?
    /// 当前正在处理的文件名。
    var fileName: String = ""
    /// 状态补充说明。
    var detail: String?

    /// 面向界面的进度文案。
    var percentText: String {
        guard let fraction else { return "—" }
        return "\(Int((fraction * 100).rounded()))%"
    }
}

// MARK: - 结果

/// 下载成功后的产物。
struct DownloadResult: Sendable {
    /// 主产物路径（合流模式是 MP4，原始流模式是视频轨 m4s）。
    let fileURL: URL
    /// 一同落盘的其它文件（原始流模式下的音频轨等）。
    let additionalFiles: [URL]
    /// 实际使用的清晰度名称。
    let qualityName: String
    /// 产物体积。
    let byteCount: Int64
    /// 总耗时。
    let elapsed: TimeInterval
}

// MARK: - 错误

/// 下载引擎的错误。
enum DownloadError: LocalizedError {
    /// 这条流不支持 Range，无法分块下载。
    case rangeUnsupported
    /// 服务器没返回 DASH 流（可能是番剧/付费内容，或地区限制）。
    case noDashStream
    /// 没有可用的视频轨。
    case noVideoStream
    /// 指定了 strict 清晰度但拿不到。
    case qualityUnavailable(requested: Int)
    /// 资源体积无法确定。
    case unknownResourceSize
    /// 写文件失败。
    case writeFailed(String)
    /// 合流失败。
    case muxFailed(String)
    /// 磁盘空间不足。
    case insufficientSpace(required: Int64, available: Int64)
    /// HTTP 状态码异常。
    case http(Int)

    var errorDescription: String? {
        switch self {
        case .rangeUnsupported:
            "该 CDN 不支持分段下载，无法使用多线程。"
        case .noDashStream:
            "这个视频没有可用的 DASH 流，可能是番剧、付费或地区限制内容。"
        case .noVideoStream:
            "没有找到可下载的视频轨。"
        case .qualityUnavailable(let requested):
            "拿不到指定的清晰度（qn=\(requested)），当前账号权限不足。"
        case .unknownResourceSize:
            "无法确定文件体积，下载已中止。"
        case .writeFailed(let reason):
            "写入文件失败：\(reason)"
        case .muxFailed(let reason):
            "音视频合流失败：\(reason)"
        case .insufficientSpace(let required, let available):
            "磁盘空间不足：需要 \(DownloadFormat.size(required))，可用 \(DownloadFormat.size(available))。"
        case .http(let code):
            "服务器返回 HTTP \(code)。"
        }
    }
}

// MARK: - 格式化

/// 下载区块自己的格式化工具。
///
/// 刻意不挂到全局 `Formatters` 上：体积与速度的展示只服务于下载界面，
/// 放在区块内部能让这一块自成一体、可以整块拿走。
enum DownloadFormat {
    /// 字节 → 人类可读体积，如 "1.23 GB"。
    static func size(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        return formatter.string(fromByteCount: bytes)
    }

    /// 字节/秒 → 人类可读速度，如 "3.4 MB/s"。
    static func speed(_ bytesPerSecond: Double) -> String {
        guard bytesPerSecond > 0 else { return "—" }
        return size(Int64(bytesPerSecond)) + "/s"
    }

    /// 秒 → 剩余时间文案，如 "约 1 分 20 秒"。
    static func remaining(_ seconds: TimeInterval?) -> String {
        guard let seconds, seconds.isFinite, seconds > 0 else { return "—" }
        if seconds < 60 { return String(format: "约 %.0f 秒", seconds) }
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if minutes < 60 { return "约 \(minutes) 分 \(secs) 秒" }
        return "约 \(minutes / 60) 小时 \(minutes % 60) 分"
    }

    /// 码率 → "5.2 Mbps"。
    static func bitrate(_ bitsPerSecond: Int) -> String {
        guard bitsPerSecond > 0 else { return "—" }
        if bitsPerSecond >= 1_000_000 {
            return String(format: "%.1f Mbps", Double(bitsPerSecond) / 1_000_000)
        }
        return String(format: "%.0f Kbps", Double(bitsPerSecond) / 1_000)
    }
}

// MARK: - 文件名

/// 文件名渲染与去重。
enum DownloadFileNaming {
    /// 把模板里的占位符替换成实际值。
    static func render(template: String,
                       request: DownloadRequest,
                       quality: DownloadQuality?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var name = template
        let replacements: [String: String] = [
            "{title}": request.title,
            "{bvid}": request.bvid,
            "{cid}": "\(request.cid)",
            "{page}": request.pageIndex.map { "P\($0)" } ?? "",
            "{quality}": quality?.name ?? "",
            "{codec}": quality?.codec ?? "",
            "{date}": dateFormatter.string(from: Date()),
        ]
        for (token, value) in replacements {
            name = name.replacingOccurrences(of: token, with: value)
        }
        // 分P 标题没进模板时，多P 视频补在末尾，避免各 P 互相覆盖
        if !template.contains("{page}"), let pageTitle = request.pageTitle,
           !pageTitle.isEmpty, pageTitle != request.title {
            let tag = request.pageIndex.map { "P\($0) " } ?? ""
            name += " - \(tag)\(pageTitle)"
        }
        return sanitize(name.isEmpty ? request.title : name)
    }

    /// 去掉文件系统不接受的字符，并压缩空白。
    static func sanitize(_ raw: String) -> String {
        let illegal = CharacterSet(charactersIn: "/\\:*?\"<>|\n\r\t")
        var cleaned = raw.components(separatedBy: illegal).joined(separator: " ")
        // 开头的点会让文件变成隐藏文件
        while cleaned.hasPrefix(".") { cleaned.removeFirst() }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        // 名字过长时截断（留出扩展名与序号的空间）
        if cleaned.count > 120 {
            cleaned = String(cleaned.prefix(120)).trimmingCharacters(in: .whitespaces)
        }
        return cleaned.isEmpty ? "bilibili-video" : cleaned
    }

    /// 在目标目录里生成一个不冲突的 URL。`overwrite == false` 时自动加序号。
    static func uniqueURL(in directory: URL, baseName: String, pathExtension: String, overwrite: Bool) -> URL {
        let candidate = directory.appendingPathComponent(baseName).appendingPathExtension(pathExtension)
        guard !overwrite, FileManager.default.fileExists(atPath: candidate.path) else {
            return candidate
        }
        for index in 2...999 {
            let numbered = directory
                .appendingPathComponent("\(baseName) (\(index))")
                .appendingPathExtension(pathExtension)
            if !FileManager.default.fileExists(atPath: numbered.path) {
                return numbered
            }
        }
        return directory
            .appendingPathComponent("\(baseName) \(UUID().uuidString.prefix(6))")
            .appendingPathExtension(pathExtension)
    }
}
