import Foundation

/// 自动更新的抽象入口。
///
/// 为什么需要这一层：Sparkle 的 XCFramework 只有 macOS slice，一旦进依赖图，iOS 构建
/// 会在**规划阶段**整体失败（不是 `import` 报错，是 XCFramework 找不到 iOS 架构）。
/// 所以 Sparkle 只能挂在 macOS 的 App target 上，共享层只认这个协议。
///
/// macOS 启动时由 `BilibiliClientApp` 注入 Sparkle 实现（见
/// `Sources/BilibiliClient/App/UpdaterController.swift`）；
/// iOS 不注入，因此设置页会整体隐藏更新区块（iOS 不提供应用内更新入口）。
@MainActor
public protocol AppUpdater: AnyObject {
    /// 当前是否可以手动检查（正在检查/下载时为 false）
    var canCheckForUpdates: Bool { get }
    /// 自动检查更新
    var automaticallyChecksForUpdates: Bool { get set }
    /// 自动下载并安装（静默更新），需要先打开自动检查
    var automaticallyDownloadsUpdates: Bool { get set }
    /// 上次检查时间（设置页展示用）
    var lastUpdateCheckDate: Date? { get }

    /// 弹标准更新窗
    func checkForUpdates()
}

/// 平台注入点。`nil` = 该平台不提供应用内更新（iOS）。
@MainActor
public enum AppUpdaterStore {
    public static var shared: AppUpdater?
}
