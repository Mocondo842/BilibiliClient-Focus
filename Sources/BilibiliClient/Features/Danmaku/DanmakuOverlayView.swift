import AVFoundation
import AppKit

/// 弹幕承载视图：挂在 `AVPlayerView.contentOverlayView` 上（画面之上、原生控件之下）。
///
/// 除了把播放头喂给引擎，它还负责**全屏过渡跟手**：
///
/// AVKit 进出全屏时是系统在主线程逐帧重排播放器（实测宽度从 980pt 平滑走到 1920pt），
/// 这里在视图布局的同一拍里把两个舞台层的 `sublayerTransform` 按 `当前宽度 / 基准宽度`
/// 缩放，于是弹幕和视频画面落在同一次 CA 事务里，天然同帧、零延迟——不存在"另起一个
/// 动画去追画面"的错位。尺寸稳定后（或 AVKit 回调过渡结束）再按最终尺寸一次性重建，
/// 文字位图恢复清晰，而字号/位置与缩放态逐像素吻合，因此收尾不会跳。
/// 重建前会先把新尺寸要用的文字位图在后台渲染好、带图换场，所以也不会闪出空窗。
///
/// 为什么是两个舞台层：滚动/顶部弹幕的 y 从**顶边**量，底部弹幕从**底边**量，
/// 而全屏与窗口画面的宽高比未必相同（差值是 `newH - newW / baseW * baseH`）。
/// 一个舞台只能锚住一条边，锚错的另一类弹幕在收尾时必须瞬移这一整段差值。
final class DanmakuOverlayNSView: NSView {
    let engine: DanmakuEngine

    weak var player: AVPlayer? {
        didSet {
            if player !== oldValue { updateTimer() }
        }
    }

    var enabled = false {
        didSet {
            if enabled != oldValue { updateTimer() }
        }
    }

    /// 滚动 + 顶部弹幕舞台：绕画面**上边**缩放
    private let topStage = NSView()
    /// 底部固定弹幕舞台：绕画面**下边**缩放
    private let bottomStage = NSView()
    /// 当前弹幕坐标/字号所依据的舞台尺寸；过渡期间保持不变，稳定后按新密度重画
    private var stageSize: CGSize = .zero
    private var lastViewportSize: CGSize = .zero
    private var viewportChangedAt: CFTimeInterval = 0
    /// 尺寸变化后还没做收尾处理（按新密度重画位图 / 重排轨道）
    private var stageNeedsRefresh = false
    /// 尺寸稳定多久后做收尾处理（秒）
    private static let rebuildQuietPeriod: TimeInterval = 0.12
    /// 尺寸变化小于该值就不处理：避免为了一两个点的抖动白重画一遍
    private static let rebuildThreshold: CGFloat = 4
    /// 容器宽高比与舞台基准相差超过该比例才重排轨道，否则只重画位图
    private static let aspectTolerance: CGFloat = 0.03
    /// 发射节拍：30Hz。弹幕位移由 Core Animation 推进，与这个频率无关。
    private static let tickInterval: TimeInterval = 1.0 / 30.0

    private var timer: Timer?
    /// AVKit 进出全屏会把覆盖层短暂摘下再挂进新窗口，停表要留宽限期
    private var detachWork: DispatchWorkItem?
    /// 字号滑杆停手后重画位图（拖动过程中不重画，避免每帧栅格化几百条）
    private var rerasterizeWork: DispatchWorkItem?
    /// 当前弹幕设置（里面带"全屏弹幕跟随比例"）
    private var settings = DanmakuSettings.current

    init(engine: DanmakuEngine, player: AVPlayer?) {
        self.engine = engine
        self.player = player
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = true

        for host in [topStage, bottomStage] {
            host.wantsLayer = true
            host.layer?.backgroundColor = NSColor.clear.cgColor
            addSubview(host)
        }
        topStage.addSubview(engine.danmakuView)
        bottomStage.addSubview(engine.bottomDanmakuView)
        // 进页面就先套用一次持久化的设置（不透明度/显示区域/类型开关/字号）
        engine.apply(DanmakuSettings.current)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        detachWork?.cancel()
        rerasterizeWork?.cancel()
        timer?.invalidate()
    }

    // MARK: - 弹幕设置

    /// 应用弹幕设置；字号缩放会立刻反映到舞台缩放上（在屏弹幕一起连续变化），
    /// 等用户停手后再按新密度重画一次文字位图，避免拖动时反复栅格化。
    func apply(settings: DanmakuSettings) {
        let fontChanged = abs(CGFloat(settings.fontScale) - engine.fontScale) > 0.001
            || abs(settings.fullscreenScale - self.settings.fullscreenScale) > 0.001
        self.settings = settings
        engine.apply(settings)
        syncStage()
        guard fontChanged else { return }
        rerasterizeWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.rerasterizeWork = nil
            self.engine.rerasterizeLiveCells()
        }
        rerasterizeWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: work)
    }

    /// 点击穿透到下层播放器（弹幕不拦截鼠标、不挡系统控件）
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    // MARK: - 布局 / 舞台跟随

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        syncStage()
    }

    override func layout() {
        super.layout()
        syncStage()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        detachWork?.cancel()
        detachWork = nil
        if window == nil {
            // 全屏过渡中途会短暂没有窗口：宽限 200ms 再停表
            let work = DispatchWorkItem { [weak self] in
                guard let self, self.window == nil else { return }
                self.detachWork = nil
                self.updateTimer()
            }
            detachWork = work
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: work)
            return
        }
        syncStage()
        updateTimer()
    }

    /// 容器尺寸变化：
    /// - 第一次拿到尺寸 → 直接作为舞台基准；
    /// - 之后每次变化（拖窗口 / 全屏过渡）→ 只更新缩放，弹幕与画面同帧放大；
    /// - 尺寸稳定后 → 按最终尺寸重建一次，恢复清晰。
    private func syncStage() {
        let size = bounds.size
        guard size.width > 1, size.height > 1 else { return }

        if stageSize == .zero {
            stageSize = size
            lastViewportSize = size
            engine.setStage(size: size)
            layoutStages(scale: 1)
            return
        }

        if abs(size.width - lastViewportSize.width) > 0.5
            || abs(size.height - lastViewportSize.height) > 0.5 {
            lastViewportSize = size
            viewportChangedAt = CACurrentMediaTime()
            stageNeedsRefresh = true
        }
        let scale = displayScale(for: size)
        // 新发射的弹幕直接按新的显示密度栅格化，避免"过渡期间发射的那批偏糊"
        engine.setDisplayScale(scale)
        layoutStages(scale: scale)
    }

    /// 弹幕自己的缩放：画面放大的倍数是 `layoutScale`，弹幕只跟其中一部分。
    ///
    /// `1 + (layoutScale - 1) × 跟随比例`：页内（layoutScale = 1）不变；
    /// 全屏时按比例少长一点，所以不会像画面那样 1:1 撑大。
    /// 再乘上用户字号设置 `fontScale`，两者互不干扰。
    private func displayScale(for size: CGSize) -> CGFloat {
        let base = max(stageSize.width, 1)
        let layoutScale = max(size.width / base, 0.02)
        let follow = CGFloat(settings.fullscreenScale)
        let danmakuGrowth = 1 + (layoutScale - 1) * follow
        return max(danmakuGrowth, 0.05) * engine.fontScale
    }

    /// 两个舞台层都按基准尺寸摆放，只差锚边；`scale` 由当前容器宽度推出。
    private func layoutStages(scale: CGFloat) {
        let base = stageSize
        guard base.width > 1, base.height > 1 else { return }
        // 绕上边缩放：p → p * scale + (0, baseH * (1 - scale))。
        // 注意 CATransform3DConcat(a, b) 的语义是"先 a 再 b"，所以要写成
        // Concat(scale, translate)：先缩放、后平移；反过来写会把平移量也乘进 scale，
        // 整层被多推下去 baseH*(scale-1)，弹幕就会往下跳、然后被底边裁掉。
        let top = CATransform3DConcat(
            CATransform3DMakeScale(scale, scale, 1),
            CATransform3DMakeTranslation(0, base.height * (1 - scale), 0)
        )
        // 绕下边缩放：p → p * scale
        let bottom = CATransform3DMakeScale(scale, scale, 1)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        topStage.frame = CGRect(x: 0, y: bounds.height - base.height,
                                width: base.width, height: base.height)
        bottomStage.frame = CGRect(x: 0, y: 0, width: base.width, height: base.height)
        topStage.layer?.sublayerTransform = top
        bottomStage.layer?.sublayerTransform = bottom
        CATransaction.commit()
    }

    /// 尺寸稳定后的收尾。
    ///
    /// 宽高比没变（页内 ↔ 全屏的常见情况）：**保持舞台基准与全部几何不动**，
    /// 只把在屏弹幕按新的显示密度重画一遍——所以既不会换行，也不会闪。
    /// 宽高比变了（分离窗口被拖成别的比例）：轨道需要重新排版，才走清屏重建。
    private func refreshStageIfNeeded() {
        guard enabled else { return }
        let size = bounds.size
        guard size.width > 1, size.height > 1, stageSize != .zero else { return }

        let widthDelta = abs(size.width - stageSize.width)
        let heightDelta = abs(size.height - stageSize.height)
        let sameAspect = abs(size.width / size.height - stageSize.width / stageSize.height)
            < stageSize.width / stageSize.height * Self.aspectTolerance

        if sameAspect {
            // 常见路径：几何一动不动，只重画位图
            engine.rerasterizeLiveCells()
            return
        }
        guard widthDelta > Self.rebuildThreshold || heightDelta > Self.rebuildThreshold else { return }
        // 宽高比变了：换成新的舞台基准（轨道按新尺寸重排），但**不清屏**——
        // 在屏弹幕保持自己的位置自然飞完，新发射的弹幕直接用新排版。
        // 清屏重建虽然能让老弹幕立刻对齐，但会换行、会闪，得不偿失。
        stageSize = size
        lastViewportSize = size
        engine.setDisplayScale(engine.fontScale)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        engine.setStage(size: size)
        layoutStages(scale: engine.fontScale)
        CATransaction.commit()
        engine.rerasterizeLiveCells()
    }

    // MARK: - 进出全屏过渡

    /// 过渡开始：无需额外处理。缩放跟随由视图布局驱动（见 `syncStage`），
    /// 与视频画面落在同一次 CA 事务里，天生对齐；文字位图等到收尾换场前统一渲染。
    func beginSizeTransition(target: CGSize?) {}

    /// 过渡结束：容器尺寸已定型，立刻按新尺寸重建（不等静默期），
    /// 让文字位图在新尺寸下重新栅格化。
    func endSizeTransition() {
        // 弹幕关着的时候不做任何收尾：否则会凭空回填出几条弹幕
        guard enabled, stageSize != .zero, player != nil else { return }
        stageNeedsRefresh = false
        refreshStageIfNeeded()
    }

    // MARK: - 节拍

    private func updateTimer() {
        let shouldRun = enabled && player != nil && window != nil
        guard shouldRun else {
            timer?.invalidate()
            timer = nil
            if !enabled {
                // 关掉弹幕开关：屏上的弹幕要立刻消失，而不是冻结在原地
                engine.clearVisible()
            }
            return
        }
        guard timer == nil else { return }
        let newTimer = Timer(timeInterval: Self.tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        newTimer.tolerance = Self.tickInterval * 0.25
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
        // 挂上就开始推进，不用等第一拍
        tick()
    }

    private func tick() {
        guard enabled, let player else { return }
        if let scale = window?.backingScaleFactor { engine.setRenderScale(scale) }
        let time = player.currentTime().seconds
        guard time.isFinite else { return }
        let playing = player.timeControlStatus == .playing

        if stageNeedsRefresh, CACurrentMediaTime() - viewportChangedAt >= Self.rebuildQuietPeriod {
            let size = bounds.size
            stageNeedsRefresh = false
            if abs(size.width - stageSize.width) > Self.rebuildThreshold
                || abs(size.height - stageSize.height) > Self.rebuildThreshold {
                refreshStageIfNeeded()
            }
        }
        engine.update(playerTime: time, isPlaying: playing, rate: player.rate)
    }
}
