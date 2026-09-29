#if os(iOS)
import AVFoundation
import AVKit
import SwiftUI

/// iOS 播放画面：系统 `AVPlayerViewController`。
///
/// 与 macOS 版（`PlayerSurfaceView` / `DanmakuPlayerView`）的差别都是平台能力差异：
/// - iOS 没有 `AVPlayerView`，只有 `AVPlayerViewController`
/// - 播放控件用系统自带的（播放/进度/倍速/全屏/画中画），不再自绘液态玻璃控制栏
/// - macOS 的「分离为独立窗口」在 iOS 没有对应概念，改由系统**画中画**承担
///
/// 弹幕层照旧挂在 `contentOverlayView` 上 —— iOS 的 `AVPlayerViewController` 同样
/// 暴露这个属性，所以「弹幕压在画面之上、控件压在弹幕之上」的层级与 macOS 一致。
struct IOSPlayerSurface: UIViewControllerRepresentable {
    let player: AVPlayer
    /// 弹幕引擎；直播没有叠加弹幕时传 nil
    let engine: DanmakuEngine?
    let danmakuEnabled: Bool
    /// 弹幕外观/行为设置（不透明度、字号、显示区域、显示类型…）
    let danmakuSettings: DanmakuSettings

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        // 系统全屏什么时候开始/结束，只有 AVKit 自己知道得最准 —— 交给 delegate，
        // 不要去猜 SwiftUI `onDisappear` 的语义（系统全屏也会让它触发）。
        controller.delegate = context.coordinator
        // 关掉「用户退出全屏就自动暂停」，见 Coordinator.disablePauseOnFullscreenExit
        context.coordinator.disablePauseOnFullscreenExit(controller)
        controller.videoGravity = .resizeAspect
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        // 「正在播放」统一由 SystemMediaCenter 上报，避免与 AVKit 互相覆盖
        controller.updatesNowPlayingInfoCenter = false

        if let engine, let overlay = controller.contentOverlayView {
            let danmaku = DanmakuOverlayView(engine: engine, player: player)
            danmaku.frame = overlay.bounds
            danmaku.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            danmaku.enabled = danmakuEnabled
            danmaku.apply(settings: danmakuSettings)
            overlay.addSubview(danmaku)
            context.coordinator.danmaku = danmaku
        }
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
        guard let danmaku = context.coordinator.danmaku else { return }
        if danmaku.player !== player {
            danmaku.player = player
        }
        danmaku.enabled = danmakuEnabled
        danmaku.apply(settings: danmakuSettings)
    }

    static func dismantleUIViewController(_ controller: AVPlayerViewController,
                                          coordinator: Coordinator) {
        coordinator.danmaku?.removeFromSuperview()
        coordinator.danmaku = nil
    }

    final class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        var danmaku: DanmakuOverlayView?

        /// 播放器最近一次**进入暂停**的时刻：系统暂停可能发生在 `willEnd` 回调之前的
        /// 几帧里，光看回调那一刻的状态会漏（见 `wasPlayingBeforeExit`）
        private var pausedSince: Date?
        private var playbackObservation: NSKeyValueObservation?
        /// 退出全屏后纠偏「被系统暂停」的定时器
        private var resumeTimer: Timer?
        /// 纠偏窗口：系统的自动暂停发生在退出过渡里，留一点尾量即可
        private static let exitResumeWindow: TimeInterval = 1.0
        /// 纠偏轮询间隔
        private static let exitResumeStep: TimeInterval = 0.1
        /// 「刚刚还在播」的判定窗口
        private static let recentlyPlayingInterval: TimeInterval = 0.35

        deinit {
            resumeTimer?.invalidate()
            playbackObservation?.invalidate()
        }

        /// 关掉 AVKit 的「用户退出全屏就自动暂停播放」。
        ///
        /// `AVPlayerViewController` 的 `canPausePlaybackWhenExitingFullScreen` 默认是开着的，
        /// 并且**只对用户经系统控件/手势退出全屏生效**（程序化退出不会触发）—— 表现就是
        /// 「点了退出全屏，播放自己停了」。这个开关在公开头文件里没有，只能探测私有设置器，
        /// 与 macOS 侧调用 `enterFullScreen:` / `exitFullScreen:` 是同一套做法；
        /// 找不到（或改了名）也不影响正确性 —— `startResumeLoopIfNeeded` 会把已经
        /// 发生的暂停纠回来。
        func disablePauseOnFullscreenExit(_ controller: AVPlayerViewController) {
            let selector = NSSelectorFromString("setCanPausePlaybackWhenExitingFullScreen:")
            guard controller.responds(to: selector) else { return }
            typealias SetFlag = @convention(c) (AnyObject, Selector, Bool) -> Void
            let call = unsafeBitCast(controller.method(for: selector), to: SetFlag.self)
            call(controller, selector, false)
        }

        /// 全屏期间盯住播放状态，记下「什么时候被按的暂停」（只记时间，不改变任何状态）。
        ///
        /// 缓冲（`waitingToPlayAtSpecifiedRate`）按「还想播」算，不算暂停。
        private func startTrackingPlayback(_ controller: AVPlayerViewController) {
            guard let player = controller.player else { return }
            playbackObservation?.invalidate()
            pausedSince = player.timeControlStatus == .paused ? Date() : nil
            playbackObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
                guard let self else { return }
                self.pausedSince = player.timeControlStatus == .paused ? (self.pausedSince ?? Date()) : nil
            }
        }

        private func stopTrackingPlayback() {
            playbackObservation?.invalidate()
            playbackObservation = nil
            pausedSince = nil
        }

        /// 退出全屏前在播吗：现在还想播（播放中/缓冲中），或者刚刚（`recentlyPlayingInterval`
        /// 内）才被按了暂停 —— 后者兜住「系统在 `willEnd` 回调之前就已经把播放器暂停了」的顺序。
        /// 用户在全屏里主动按的暂停距他再点退出通常远超过这个窗口，所以不会被误恢复。
        private func wasPlayingBeforeExit(_ player: AVPlayer) -> Bool {
            if player.timeControlStatus != .paused { return true }
            guard let pausedSince else { return false }
            return Date().timeIntervalSince(pausedSince) < Self.recentlyPlayingInterval
        }

        /// 退出全屏前在播的话，把系统「退出即暂停」造成的暂停纠回来。
        ///
        /// 退出前本来就暂停的（用户在全屏里按了暂停）不动。窗口很短：系统暂停发生在退出
        /// 过渡里，这期间内嵌控件还没交回用户，不会跟用户随后的操作打架。
        private func startResumeLoopIfNeeded(_ controller: AVPlayerViewController) {
            resumeTimer?.invalidate()
            resumeTimer = nil
            guard let player = controller.player, wasPlayingBeforeExit(player) else { return }
            let deadline = Date().addingTimeInterval(Self.exitResumeWindow)
            let timer = Timer(timeInterval: Self.exitResumeStep, repeats: true) { [weak self, weak player] timer in
                guard let player, Date() < deadline else {
                    timer.invalidate()
                    self?.resumeTimer = nil
                    return
                }
                if player.timeControlStatus != .playing, player.rate == 0 {
                    player.play()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            resumeTimer = timer
            timer.fire()
        }

        /// 系统全屏开始：先把「系统正在全屏」标上。
        /// 页面随后收到的 `onDisappear` 因此知道自己只是被盖住，
        /// 不会去停播放、清弹幕 —— 那正是「点全屏就自动暂停 + 弹幕立刻消失」的来源。
        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            PlayerPresentationState.shared.setSystemFullscreen(true)
            // 进入全屏的这一刻再关一次：退出时读这个开关的就是这个实例
            disablePauseOnFullscreenExit(playerViewController)
            startTrackingPlayback(playerViewController)
        }

        /// 系统全屏结束：等退出动画真正跑完再解除标记，
        /// 过渡途中页面收到的 `onAppear` / `onDisappear` 都不会去动播放器。
        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            startResumeLoopIfNeeded(playerViewController)
            coordinator.animate(alongsideTransition: nil) { [weak self] _ in
                PlayerPresentationState.shared.setSystemFullscreen(false)
                self?.stopTrackingPlayback()
            }
        }

        /// 退出全屏前告诉系统「内嵌那套 UI 还在原位」，它才会走**原生的一路缩回原位**
        /// 动画；这里报 false（或者内嵌 UI 已经不存在）就只剩下滑渐隐。
        /// 播放器全程没被拆，所以恒为 true。
        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            restoreUserInterfaceForFullScreenExitWithCompletionHandler completionHandler: @escaping (Bool) -> Void
        ) {
            completionHandler(true)
        }
    }
}
#endif
