import AVFoundation
import AVKit
import SwiftUI
import SwiftUIX

/// 播放画面：系统 `AVPlayerView` 只负责画面与全屏（含全屏动画），
/// 播放控件改为自绘的液态玻璃控制栏（`PlayerControlBar`）。
///
/// 三样东西都挂在 `contentOverlayView` 上，因此会跟着播放器一起被系统搬进
/// 全屏窗口：弹幕层（画面之上）、自绘控制栏（弹幕之上）。AVKit 自带控件条
/// 整体关闭（`controlsStyle = .none`），既是为了换成简洁样式，也顺带绕开
/// "未就绪播放项带时间轴会触发 AVKit 内部 precondition 崩溃"那个坑。
/// 全屏仍走 AVKit：控件栏上的全屏按钮与画面双击都调 `enterFullScreen:`，
/// 与系统全屏动画、弹幕跟随完全一致。
struct PlayerSurfaceView: NSViewRepresentable {
    let player: AVPlayer
    /// 弹幕引擎；直播没有叠加弹幕时传 nil
    let engine: DanmakuEngine?
    let danmakuEnabled: Bool
    /// 弹幕外观/行为设置（不透明度、字号、显示区域、显示类型…）
    let danmakuSettings: DanmakuSettings
    /// 自绘控制栏的输入（直播/点播由 `controls.isLive` 区分）
    let controls: PlayerBarConfig

    func makeNSView(context: Context) -> DanmakuPlayerView {
        let view = DanmakuPlayerView()
        view.setPlayer(player)
        view.videoGravity = .resizeAspect
        view.allowsPictureInPicturePlayback = true
        // AVKit 控件条整体关闭：播放/进度/音量/倍速/画质都由自绘控制栏负责
        view.controlsStyle = .none
        // “正在播放”统一由 SystemMediaCenter 上报，避免与 AVKit 互相覆盖
        view.updatesNowPlayingInfoCenter = false
        if let engine {
            view.installDanmaku(engine: engine, enabled: danmakuEnabled)
        }
        view.applyDanmakuSettings(danmakuSettings)
        view.installControls(controls)
        return view
    }

    func updateNSView(_ view: DanmakuPlayerView, context: Context) {
        view.setPlayer(player)
        view.setDanmakuEnabled(danmakuEnabled)
        view.applyDanmakuSettings(danmakuSettings)
        view.updateControls(controls)
        view.attachOverlaysIfNeeded()
    }

    static func dismantleNSView(_ view: DanmakuPlayerView, coordinator: ()) {
        PlaybackMenuState.shared.detachPlayerView(view)
    }
}

/// `AVPlayerView` 子类：在画面之上挂弹幕层与自绘控制栏，并保留页面原有的键盘操作。
///
/// 两个要点：
/// 1. 控件条由自绘控制栏取代（`controlsStyle = .none`），全屏仍走 AVKit 的
///    `enterFullScreen:` / `exitFullScreen:`（探测私有 selector 再调用），因此
///    全屏动画与弹幕跟随和原来完全一致。
/// 2. AVKit 的内部子视图会截走 hit-test 与第一响应者，直接重写 `keyDown` 在真实
///    点击画面后收不到按键，因此快捷键改用窗口级本地事件监听实现。
final class DanmakuPlayerView: AVPlayerView {
    /// 页面快捷键（空格 / ←→）回调：与控制栏共用同一套动作入口
    var onSpace: (@MainActor () -> Void)?
    var onSkip: (@MainActor (Double) -> Void)?

    private var danmakuView: DanmakuOverlayNSView?
    private var danmakuEngine: DanmakuEngine?
    private var danmakuEnabled = false
    private var danmakuSettings: DanmakuSettings?
    private var attachScheduled = false

    /// 自绘控制栏的状态中枢（含承载层），与弹幕层同挂在 contentOverlayView 上
    let controlsModel = PlayerBarModel()
    private var controlsHost: PlayerControlsHostView?

    /// SwiftUIX 的事件监听：start/stop 生命周自带，不用自己 add/remove 本地监视器
    private var keyMonitor: NSEventMonitor?
    /// AVKit 原生全屏期间，播放器在 AVKit 自己的全屏窗口里
    private var isNativeFullscreen = false
    private var holdTask: Task<Void, Never>?
    private var rightKeyHeld = false
    private var holdTriggered = false
    private var rateBeforeHold: Float = 1
    private var wasPlayingBeforeHold = false

    deinit {
        holdTask?.cancel()
        keyMonitor?.stop()
    }

    // MARK: - 播放器

    /// 设置/更新播放器，并把播放器交给控制栏状态中枢（时间/状态按节拍自取）。
    func setPlayer(_ player: AVPlayer?) {
        if self.player !== player {
            self.player = player
            danmakuView?.player = player
        }
        controlsModel.bind(player: player)
    }

    // MARK: - 弹幕与控制栏

    /// 把弹幕层挂到 AVKit 的内容覆盖层（画面之上、自绘控制栏之下）。
    func installDanmaku(engine: DanmakuEngine, enabled: Bool) {
        danmakuEngine = engine
        danmakuEnabled = enabled
        attachOverlaysIfNeeded()
        DispatchQueue.main.async { [weak self] in self?.attachOverlaysIfNeeded() }
    }

    func setDanmakuEnabled(_ enabled: Bool) {
        danmakuEnabled = enabled
        danmakuView?.enabled = enabled
    }

    /// 把播放页里的弹幕设置推给渲染层（不透明度/字号/显示区域/显示类型等）
    func applyDanmakuSettings(_ settings: DanmakuSettings) {
        danmakuSettings = settings
        danmakuView?.apply(settings: settings)
    }

    /// 装载自绘控制栏：全屏/画中画这类要直接操作播放器的动作在这里接线
    func installControls(_ config: PlayerBarConfig) {
        updateControls(config)
        controlsModel.onToggleFullscreen = { [weak self] in self?.performToggleFullscreen() }
        controlsModel.onTogglePictureInPicture = { [weak self] in self?.performTogglePictureInPicture() }
        controlsModel.supportsPictureInPicture = Self.supportsPictureInPicture()
        attachOverlaysIfNeeded()
        DispatchQueue.main.async { [weak self] in self?.attachOverlaysIfNeeded() }
    }

    /// SwiftUI 每轮更新推入的控制栏配置（状态与动作）；页面快捷键与控制栏共用同一入口
    func updateControls(_ config: PlayerBarConfig) {
        controlsModel.apply(config)
        onSpace = { [weak self] in self?.controlsModel.togglePlay() }
        onSkip = { [weak self] in self?.controlsModel.skip(by: $0) }
    }

    /// 把弹幕层与自绘控制栏挂到 `contentOverlayView`（幂等；未就绪时由 layout 再试）。
    /// 控制栏后挂，落在弹幕层之上，但两者都在画面之上、互不拦截鼠标。
    func attachOverlaysIfNeeded() {
        guard let overlay = contentOverlayView else { return }
        if danmakuView == nil, let engine = danmakuEngine {
            let view = DanmakuOverlayNSView(engine: engine, player: player)
            view.enabled = danmakuEnabled
            if let danmakuSettings { view.apply(settings: danmakuSettings) }
            view.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
                view.topAnchor.constraint(equalTo: overlay.topAnchor),
                view.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
            ])
            danmakuView = view
        }
        if controlsHost == nil {
            let host = PlayerControlsHostView(model: controlsModel)
            host.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(host)
            NSLayoutConstraint.activate([
                host.leadingAnchor.constraint(equalTo: overlay.leadingAnchor),
                host.trailingAnchor.constraint(equalTo: overlay.trailingAnchor),
                host.topAnchor.constraint(equalTo: overlay.topAnchor),
                host.bottomAnchor.constraint(equalTo: overlay.bottomAnchor),
            ])
            controlsHost = host
        }
    }

    override func layout() {
        super.layout()
        // 布局过程中不能改视图树（会触发 layoutSubtreeIfNeeded 递归告警），延后一拍再挂
        guard (danmakuView == nil && danmakuEngine != nil) || controlsHost == nil, !attachScheduled else { return }
        attachScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.attachScheduled = false
            self.attachOverlaysIfNeeded()
        }
    }

    // MARK: - 键盘

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if delegate == nil { delegate = self }
        // 挂上窗口即登记为"当前播放器"，顶部菜单的全屏开关据此找到它
        if window != nil {
            PlaybackMenuState.shared.attachPlayerView(self)
        } else {
            PlaybackMenuState.shared.detachPlayerView(self)
        }
        keyMonitor?.stop()
        keyMonitor = nil
        cancelHold()
        guard window != nil else { return }
        // 本地键盘监听（空格 / ← / →）：返回 nil 表示吞掉事件，交回原事件则继续分发
        keyMonitor = NSEventMonitor(context: .local, matching: [.keyDown, .keyUp]) { [weak self] event in
            guard let self, self.handleKey(event) else { return event }
            return nil
        }
        keyMonitor?.start()
    }

    /// 返回 true 表示事件已被播放器消费。
    private func handleKey(_ event: NSEvent) -> Bool {
        guard let window, let eventWindow = event.window, eventWindow.isKeyWindow else { return false }
        // AVKit 原生全屏时事件属于 AVKit 的全屏窗口
        guard eventWindow === window || isNativeFullscreen else { return false }
        // 正在输入框里打字（搜索框等）：不抢按键
        if let responder = eventWindow.firstResponder as? NSView,
           responder is NSTextField || responder is NSTextView {
            return false
        }
        // 带命令/控制/option 的组合键留给系统与菜单
        let flags = event.modifierFlags
        if flags.contains(.command) || flags.contains(.control) || flags.contains(.option) {
            return false
        }
        switch event.type {
        case .keyDown:
            switch event.keyCode {
            case 49:  // 空格
                guard !event.isARepeat else { return true }
                onSpace?()
                return true
            case 123:  // ←
                guard !event.isARepeat else { return true }
                onSkip?(-15)
                return true
            case 124:  // →
                // 按住期间的自动重复不重置长按计时
                guard !event.isARepeat else { return true }
                rightKeyHeld = true
                holdTriggered = false
                holdTask?.cancel()
                holdTask = Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .milliseconds(400))
                    guard let self, self.rightKeyHeld, !self.holdTriggered else { return }
                    self.holdTriggered = true
                    self.beginFastForward()
                }
                return true
            default:
                return false
            }
        case .keyUp:
            guard event.keyCode == 124 else { return false }
            holdTask?.cancel()
            holdTask = nil
            if holdTriggered {
                endFastForward()
            } else {
                onSkip?(15)
            }
            rightKeyHeld = false
            holdTriggered = false
            return true
        default:
            return false
        }
    }

    /// 长按右方向键：进入 2 倍速（暂停时也以 2 倍速开始播放）
    private func beginFastForward() {
        guard let player else { return }
        rateBeforeHold = player.rate
        wasPlayingBeforeHold = player.timeControlStatus == .playing
        if wasPlayingBeforeHold {
            player.rate = 2
        } else {
            player.playImmediately(atRate: 2)
        }
    }

    private func endFastForward() {
        guard let player else { return }
        if wasPlayingBeforeHold {
            player.rate = rateBeforeHold > 0 ? rateBeforeHold : 1
        } else {
            player.pause()
        }
    }

    /// 交给 AVKit 自己的全屏入口——自绘控制栏上的全屏按钮走的就是它。
    /// `enterFullScreen:` / `exitFullScreen:` 没有出现在公开头文件里，先探测再调用，
    /// 不可用时返回 false，由调用方退回窗口全屏。
    func toggleNativeFullscreen() -> Bool {
        let name = isNativeFullscreen ? "exitFullScreen:" : "enterFullScreen:"
        let selector = NSSelectorFromString(name)
        guard responds(to: selector) else { return false }
        _ = perform(selector, with: nil)
        return true
    }

    /// 控制栏的全屏按钮：优先 AVKit 原生全屏（动画、弹幕跟随一致），系统不提供再退回窗口全屏
    func performToggleFullscreen() {
        guard toggleNativeFullscreen() else {
            window?.toggleFullScreen(nil)
            return
        }
    }

    /// 控制栏的画中画按钮：调 AVKit 自己的画中画入口（与原生控件条按钮同一条路径）
    func performTogglePictureInPicture() {
        let selector = NSSelectorFromString("pictureInPictureButtonTapped:")
        guard responds(to: selector) else { return }
        _ = perform(selector, with: nil)
    }

    static func supportsPictureInPicture() -> Bool {
        AVPlayerView().responds(to: NSSelectorFromString("pictureInPictureButtonTapped:"))
    }

    private func cancelHold() {
        guard rightKeyHeld else { return }
        holdTask?.cancel()
        holdTask = nil
        if holdTriggered {
            endFastForward()
        }
        rightKeyHeld = false
        holdTriggered = false
    }
}

extension DanmakuPlayerView: AVPlayerViewDelegate {
    /// 全屏动画开始：弹幕层冻结推进、整层缩放跟随，并开始预热目标尺寸的文字位图。
    /// 这条路径由 AVKit 精确开合，比轮询尺寸判断可靠得多。
    func playerViewWillEnterFullScreen(_ playerView: AVPlayerView) {
        isNativeFullscreen = true
        PlaybackMenuState.shared.setFullscreen(true)
        controlsModel.setFullscreen(true)
        danmakuView?.beginSizeTransition(target: window?.screen?.frame.size
            ?? NSScreen.main?.frame.size)
    }

    func playerViewDidEnterFullScreen(_ playerView: AVPlayerView) {
        danmakuView?.endSizeTransition()
    }

    func playerViewWillExitFullScreen(_ playerView: AVPlayerView) {
        danmakuView?.beginSizeTransition(target: nil)
    }

    func playerViewDidExitFullScreen(_ playerView: AVPlayerView) {
        isNativeFullscreen = false
        PlaybackMenuState.shared.setFullscreen(false)
        controlsModel.setFullscreen(false)
        danmakuView?.endSizeTransition()
    }
}
