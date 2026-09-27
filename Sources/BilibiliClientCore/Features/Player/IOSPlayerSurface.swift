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

    final class Coordinator {
        var danmaku: DanmakuOverlayView?
    }
}
#endif
