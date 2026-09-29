import Foundation

/// iOS 系统全屏（`AVPlayerViewController` 自带的全屏）是否正在呈现。
///
/// 系统全屏的做法是把播放内容换到一个**新的全屏 VC（可能还有新窗口）**里去，
/// 我们这一页会被整个盖住，SwiftUI 于是会发 `onDisappear`。但那**不是**"用户离开了
/// 播放页"：
///
/// - 照着 `onDisappear` 去 `player.stop()`，就会「一点全屏就自动暂停」；
/// - 顺带 `danmaku.reset()`，就会「弹幕立刻消失」；
/// - 播放器被拆掉之后，系统也失去了退出时可以平滑缩回去的落点，原生退出动画
///   只能退化成下滑渐隐。
///
/// 所以这里的状态必须由官方给的正确时机驱动——`AVPlayerViewControllerDelegate`
/// 的全屏开始/结束回调（见 `IOSPlayerSurface`），而不是靠猜 `onDisappear` 的语义。
///
/// 只在事件里读写、不参与渲染，所以不需要做成 `ObservableObject`。
/// 也刻意**不加 `@MainActor`**：`AVPlayerViewControllerDelegate` 的回调在 SDK 里
/// 并不是 main-actor 隔离的，加隔离会逼出 `assumeIsolated`（推论错误就崩）。
/// 这里所有读写都发生在主线程（AVKit 委托回调 + SwiftUI 生命周期），是纯值传递。
///
/// macOS 没有这个形态：它的全屏是窗口全屏，页面不会 `disappear`，因此这里恒为
/// `false`，调用点的行为与改动前完全一致。
final class PlayerPresentationState {
    static let shared = PlayerPresentationState()

    /// 系统正在（或即将）呈现全屏播放
    private(set) var isSystemFullscreen = false

    private init() {}

    func setSystemFullscreen(_ value: Bool) {
        isSystemFullscreen = value
    }
}
