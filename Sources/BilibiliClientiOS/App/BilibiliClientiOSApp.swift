import SwiftUI
import BilibiliClientCore

/// iOS（iPhone / iPad）App 入口。
///
/// 与 macOS 入口（`Sources/BilibiliClient/App/BilibiliClientApp.swift`）的区别都是
/// 平台能力差异，不是功能取舍：
/// - 没有 `Window` / `MenuBarExtra` / `Commands`，改用 `WindowGroup`
/// - 没有 Sparkle：iOS 不做应用内自动更新入口
/// - 没有「关闭窗口行为」（菜单栏常驻 / 询问）：iOS 无菜单栏
/// 其余业务全部走共享层 `BilibiliClientCore`。
@main
struct BilibiliClientiOSApp: App {
    @StateObject private var session = SessionStore.shared
    @StateObject private var router = AppRouter.shared

    init() {
        // 日志后端必须在任何 AppLog 调用之前装好
        AppLog.bootstrap()
        AppLog.app.info("启动 iOS", metadata: ["version": "\(BuildInfo.version)", "build": "\(BuildInfo.build)"])
        URLCache.shared = URLCache(memoryCapacity: 8 * 1024 * 1024,
                                   diskCapacity: 128 * 1024 * 1024)
        BiliImages.install()
        // 系统「正在播放」与耳机/控制中心媒体键
        SystemMediaCenter.shared.install()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(router)
        }
    }
}
