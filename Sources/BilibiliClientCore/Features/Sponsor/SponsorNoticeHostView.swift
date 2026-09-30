#if os(macOS)
import AppKit
import SwiftUI

/// 空降提示卡片在 macOS 上的宿主。
///
/// 为什么需要这一层，而不是让卡片当播放组件的 SwiftUI 同级视图：
/// `VideoPlayerSurface` 的 ZStack 里放的是 `AVPlayerView`（`NSViewRepresentable`），
/// 它在 AppKit 层会盖住同级 SwiftUI 视图；更要命的是进全屏时 AVKit 会把播放器
/// 搬进另一个窗口，页面里的浮层根本不会跟过去。控制栏与弹幕层当初也是因为
/// 同样的原因挂在 `contentOverlayView` 上，这里沿用同一条路径。
final class SponsorNoticeHostView: NSView {

    private let model: PlayerBarModel
    private var hostingView: NSHostingView<SponsorNoticeCard>?
    /// 当前卡片对应的提示 id，用来判断是否需要重建。
    private var shownNoticeID: UUID?

    init(model: PlayerBarModel) {
        self.model = model
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 把卡片同步到模型当前状态；没有提示时整块移除。
    /// 由 `DanmakuPlayerView.updateControls` 在每次配置推入后调用。
    func sync() {
        guard let notice = model.sponsorNotice else {
            hostingView?.removeFromSuperview()
            hostingView = nil
            shownNoticeID = nil
            return
        }
        // 同一条提示不重建（避免每次 SwiftUI 更新都把卡片重置一遍）
        if hostingView != nil, shownNoticeID == notice.id { return }

        hostingView?.removeFromSuperview()

        let card = SponsorNoticeCard(
            notice: notice,
            onUndo: { [weak self] in self?.model.onSponsorUndo() },
            onDismiss: { [weak self] in self?.model.onSponsorDismiss() }
        )
        let host = NSHostingView(rootView: card)
        host.translatesAutoresizingMaskIntoConstraints = false
        addSubview(host)
        NSLayoutConstraint.activate([
            host.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            host.topAnchor.constraint(equalTo: topAnchor, constant: 14),
        ])
        hostingView = host
        shownNoticeID = notice.id
    }

    /// 只有卡片本身接收点击，其余区域透给下层（播放器双击全屏、控制栏都还在）。
    override func hitTest(_ point: NSPoint) -> NSView? {
        let hit = super.hitTest(point)
        return hit === self ? nil : hit
    }
}
#endif
