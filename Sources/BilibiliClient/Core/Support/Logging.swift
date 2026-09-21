import Foundation
import Logging
import os

/// 全应用日志入口。
///
/// 用 swift-log 的 `Logger` 门面，后端接本机的 `os.Logger`：日志进系统统一日志，
/// 可以用 Console.app 或 `log stream --predicate 'subsystem == "com.codex.bilibili-client"'`
/// 按 category 过滤，也能在 Xcode 控制台直接看；不额外落盘，release 构建里的
/// `.debug` 级别默认不持久化，开销可以忽略。
///
/// 用法：`AppLog.live.info("…")`、`AppLog.network.debug("…")`。
enum AppLog {
    /// App 生命周期、启动与更新
    static let app = Logger(label: "app")
    /// B 站 REST 接口请求
    static let network = Logger(label: "network")
    /// 播放器、本地 HLS 代理、分片解析
    static let player = Logger(label: "player")
    /// 视频弹幕与渲染
    static let danmaku = Logger(label: "danmaku")
    /// 直播间与直播弹幕 WebSocket
    static let live = Logger(label: "live")
    /// 登录态、钥匙串、Cookie
    static let auth = Logger(label: "auth")

    /// 安装日志后端。整个进程只装一次。
    ///
    /// 必须在第一次取用上面任意一个 `Logger` 之前调用——App 里就是 `BilibiliClientApp.init()`。
    static func bootstrap() {
        guard !installed else { return }
        installed = true
        LoggingSystem.bootstrap { OSLogHandler(label: $0) }
    }

    private static var installed = false
}

/// `os.Logger` 的别名。
///
/// swift-log 和 `os` 各有一个叫 `Logger` 的类型，同文件 import 之后裸写 `Logger` 会有歧义，
/// 所以系统日志这边统一走这个别名，swift-log 那边统一写 `Logging.Logger`。
private typealias SystemLog = os.Logger

/// swift-log 后端：把日志写进系统统一日志。
///
/// 消息统一按 `.public` 输出，否则 Console.app 里只会看到 `<private>`。换来可读性的代价是
/// **不能把 cookie、token、WBI 签名、扫码头这类东西写进日志**——需要排查时只记路径与状态码。
private struct OSLogHandler: LogHandler {
    var logLevel: Logging.Logger.Level = .debug
    var metadata: Logging.Logger.Metadata = [:]

    private let logger: SystemLog

    init(label: String) {
        logger = SystemLog(subsystem: Bundle.main.bundleIdentifier ?? "com.codex.bilibili-client",
                           category: label)
    }

    subscript(metadataKey key: String) -> Logging.Logger.MetadataValue? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    func log(event: LogEvent) {
        let text = render(message: event.message, metadata: event.metadata)
        switch event.level {
        case .trace: logger.trace("\(text, privacy: .public)")
        case .debug: logger.debug("\(text, privacy: .public)")
        case .info: logger.info("\(text, privacy: .public)")
        case .notice: logger.notice("\(text, privacy: .public)")
        case .warning: logger.warning("\(text, privacy: .public)")
        case .error: logger.error("\(text, privacy: .public)")
        case .critical: logger.critical("\(text, privacy: .public)")
        }
    }

    /// 把本条与 handler 上挂着的 metadata 合成 `k=v k=v` 附在正文之后。
    private func render(message: Logging.Logger.Message, metadata: Logging.Logger.Metadata?) -> String {
        var merged = self.metadata
        for (key, value) in metadata ?? [:] {
            merged[key] = value
        }
        guard !merged.isEmpty else { return "\(message)" }
        let pairs = merged
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        return "\(message) [\(pairs)]"
    }
}
