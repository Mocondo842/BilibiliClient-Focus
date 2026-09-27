import AppKit
import AVFoundation
import SwiftUI

// MARK: - 配置

/// 自绘控制栏的输入：展示所需状态 + 宿主动作闭包。
///
/// 由 SwiftUI 播放组件在每次更新时整体推给 `PlayerBarModel.apply(_:)`
/// （与 `PlayerSurfaceView.updateNSView` 同一条路径）。
/// 全屏与画中画不在此处：它们要直接操作 `AVPlayerView`，由 `DanmakuPlayerView` 自己接。
struct PlayerBarConfig {
    /// 直播流没有时间轴，改显示"直播"徽标
    var isLive = false
    /// 弹幕开关状态；nil 表示这个播放器没有弹幕层（直播），不显示按钮
    var danmakuEnabled: Bool?
    /// 清晰度列表；空表示不显示画质入口（直播）
    var qualities: [PlayerController.Quality] = []
    var currentQualityId: Int?
    var onTogglePlay: @MainActor () -> Void = {}
    var onSeek: @MainActor (Double) -> Void = { _ in }
    var onSkip: @MainActor (Double) -> Void = { _ in }
    var onToggleDanmaku: @MainActor () -> Void = {}
    var onSelectQuality: @MainActor (PlayerController.Quality) -> Void = { _ in }
}

// MARK: - 状态中枢

/// 自绘控制栏的状态中枢。
///
/// 它由 `DanmakuPlayerView` 持有（而不是 SwiftUI 侧）：控制栏必须活在
/// `AVPlayerView.contentOverlayView` 里，才能跟着播放器一起被系统搬进全屏窗口。
/// 时间/播放状态按 0.25s 节拍从 `AVPlayer` 读取，只刷新这个小对象，
/// 不往播放页 body 发布，避免整页重算（与 PlayerController 的取舍一致）。
@MainActor
final class PlayerBarModel: ObservableObject {
    // MARK: 宿主推入的状态
    @Published private(set) var isLive = false
    @Published private(set) var hasDanmakuToggle = false
    @Published private(set) var danmakuEnabled = true
    @Published private(set) var qualities: [PlayerController.Quality] = []
    @Published private(set) var currentQualityId: Int?
    /// 画中画入口是否可用（AVKit 未提供该入口时隐藏按钮）
    @Published var supportsPictureInPicture = false

    // MARK: 从 AVPlayer 读出的状态
    @Published private(set) var position: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var isPlaying = false
    @Published private(set) var isBuffering = false
    @Published private(set) var volume: Float = 1
    @Published private(set) var isMuted = false
    @Published private(set) var isFullscreen = false
    @Published private(set) var speed: Float = 1

    // MARK: 交互状态
    @Published private(set) var isScrubbing = false
    @Published private(set) var scrubPreview: Double?
    @Published private(set) var isBarVisible = true

    static let speedOptions: [Float] = [0.5, 0.75, 1, 1.25, 1.5, 2]
    /// 鼠标不动多久后收起控制栏（播放中才收）
    private static let hideDelay: Duration = .seconds(2.5)

    var onToggleFullscreen: @MainActor () -> Void = {}
    var onTogglePictureInPicture: @MainActor () -> Void = {}

    private var config = PlayerBarConfig()
    private weak var player: AVPlayer?
    private var tickTimer: Timer?
    private var hideTask: Task<Void, Never>?
    private var hoveringBar = false

    // MARK: - 生命周期

    /// 绑定播放器并启动节拍；换 player 时重新绑（倍速偏好会套用到新播放器）。
    func bind(player: AVPlayer?) {
        if self.player !== player {
            self.player = player
            if let player {
                player.defaultRate = speed
                player.volume = volume
                player.isMuted = isMuted
            }
        }
        startTicking()
        refresh()
        pokeActivity()
    }

    func detach() {
        player = nil
        tickTimer?.invalidate()
        tickTimer = nil
        hideTask?.cancel()
        hideTask = nil
    }

    /// 宿主每次 SwiftUI 更新时推入的配置
    func apply(_ config: PlayerBarConfig) {
        self.config = config
        isLive = config.isLive
        if let enabled = config.danmakuEnabled {
            hasDanmakuToggle = true
            danmakuEnabled = enabled
        } else {
            hasDanmakuToggle = false
        }
        qualities = config.qualities
        currentQualityId = config.currentQualityId
    }

    func setFullscreen(_ fullscreen: Bool) {
        isFullscreen = fullscreen
        pokeActivity()
    }

    private func startTicking() {
        guard tickTimer == nil else { return }
        // 0.25s 足够让时间码与进度条看起来连续，又不至于频繁刷新
        tickTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    private func refresh() {
        guard let player else { return }
        let seconds = player.currentTime().seconds
        if seconds.isFinite, !isScrubbing {
            position = max(seconds, 0)
        }
        if let item = player.currentItem {
            let total = item.duration.seconds
            duration = (total.isFinite && total > 0) ? total : 0
        }
        isPlaying = player.timeControlStatus == .playing
        isBuffering = player.timeControlStatus == .waitingToPlayAtSpecifiedRate
        volume = player.volume
        isMuted = player.isMuted
        if !isPlaying, !isScrubbing {
            // 暂停时控制栏常驻，避免找不到播放键
            isBarVisible = true
        }
    }

    // MARK: - 控制栏显隐

    /// 鼠标在播放区里动了：显示控制栏并重新计时收起
    func pokeActivity() {
        isBarVisible = true
        hideTask?.cancel()
        hideTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: Self.hideDelay)
            guard !Task.isCancelled else { return }
            self?.hideIfIdle()
        }
    }

    /// 鼠标离开播放区：播放中就立刻收起
    func mouseLeftPlayer() {
        hideTask?.cancel()
        hideTask = nil
        hideIfIdle()
    }

    /// 指针悬停在控制栏上：不收起
    func setHoveringBar(_ hovering: Bool) {
        hoveringBar = hovering
        if hovering { pokeActivity() }
    }

    private func hideIfIdle() {
        guard isPlaying, !isScrubbing, !hoveringBar else { return }
        isBarVisible = false
    }

    // MARK: - 播放控制

    var hasTimeline: Bool { !isLive && duration > 0 }
    /// 进度条上显示的时间：拖动中优先显示拖到的位置
    var displayPosition: Double { scrubPreview ?? position }

    func togglePlay() {
        config.onTogglePlay()
        pokeActivity()
        Task { @MainActor [weak self] in self?.refresh() }
    }

    func beginScrub() {
        isScrubbing = true
        scrubPreview = position
    }

    func updateScrub(_ value: Double) {
        isScrubbing = true
        scrubPreview = max(value, 0)
        pokeActivity()
    }

    func endScrub() {
        let target = scrubPreview
        isScrubbing = false
        scrubPreview = nil
        if let target {
            position = target
            config.onSeek(target)
        }
        pokeActivity()
    }

    /// 拖动进度条时的快进快退（供快捷键复用同一入口）
    func skip(by seconds: Double) {
        config.onSkip(seconds)
        pokeActivity()
    }

    func setSpeed(_ newSpeed: Float) {
        speed = newSpeed
        if let player {
            player.defaultRate = newSpeed
            if player.timeControlStatus == .playing {
                player.rate = newSpeed
            }
        }
        pokeActivity()
    }

    func setVolume(_ value: Float) {
        volume = value
        isMuted = value <= 0
        if let player {
            player.volume = value
            player.isMuted = value <= 0
        }
        pokeActivity()
    }

    func toggleMute() {
        setVolume(isMuted ? max(volume, 0.5) : 0)
    }

    func toggleDanmaku() {
        config.onToggleDanmaku()
        danmakuEnabled.toggle()
        pokeActivity()
    }

    func selectQuality(_ quality: PlayerController.Quality) {
        config.onSelectQuality(quality)
        pokeActivity()
    }

    func toggleFullscreen() {
        onToggleFullscreen()
        pokeActivity()
    }

    func togglePictureInPicture() {
        onTogglePictureInPicture()
        pokeActivity()
    }
}

// MARK: - 控制栏 UI

/// 自绘播放控制栏：一条液态玻璃胶囊，悬停/移动鼠标时浮现，播放中闲置 2.5s 自动收起。
///
/// 内容按"简洁优先"取舍：播放/暂停 · 进度+时间 · 倍速 · 音量 · 弹幕 · 画质 · 画中画 · 全屏。
/// 直播没有时间轴，进度区换成"直播"徽标。
struct PlayerControlBar: View {
    @ObservedObject var model: PlayerBarModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 10) {
            Button {
                model.togglePlay()
            } label: {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .help(model.isPlaying ? "暂停（空格）" : "播放（空格）")

            if model.hasTimeline {
                Text(Formatters.duration(Int(model.displayPosition)))
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .frame(width: 48, alignment: .leading)

                slider

                Text(Formatters.duration(Int(model.duration)))
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .trailing)
            } else {
                liveBadge
                Spacer(minLength: 4)
            }

            speedMenu
            volumeControl

            if model.hasDanmakuToggle {
                Button {
                    model.toggleDanmaku()
                } label: {
                    Image(systemName: model.danmakuEnabled ? "text.bubble.fill" : "text.bubble")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 22, height: 22)
                }
                .help(model.danmakuEnabled ? "关闭弹幕（⌘D）" : "开启弹幕（⌘D）")
            }

            if !model.qualities.isEmpty {
                qualityMenu
            }

            if model.supportsPictureInPicture {
                Button {
                    model.togglePictureInPicture()
                } label: {
                    Image(systemName: "pip")
                        .font(.system(size: 11, weight: .semibold))
                        .frame(width: 22, height: 22)
                }
                .help("画中画")
            }

            Button {
                model.toggleFullscreen()
            } label: {
                Image(systemName: model.isFullscreen
                      ? "arrow.down.right.and.arrow.up.left"
                      : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .help(model.isFullscreen ? "退出全屏（⌘F）" : "全屏（⌘F）")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white.opacity(0.92))
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background {
            Capsule()
                .fill(.white.opacity(0.06))
                .glassEffect(.regular, in: .capsule)
        }
        .onHover { model.setHoveringBar($0) }
        .opacity(model.isBarVisible ? 1 : 0)
        .offset(y: model.isBarVisible ? 0 : 6)
        .allowsHitTesting(model.isBarVisible)
        .animation(.easeOut(duration: 0.18), value: model.isBarVisible)
    }

    // MARK: 进度

    private var slider: some View {
        Slider(
            value: Binding(
                get: { model.displayPosition },
                set: { model.updateScrub($0) }
            ),
            in: 0...max(model.duration, 1)
        ) { editing in
            if editing {
                model.beginScrub()
            } else {
                model.endScrub()
            }
        }
        .controlSize(.small)
        .tint(.white)
    }

    private var liveBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(.red)
                .frame(width: 6, height: 6)
            Text("直播")
                .font(.system(size: 11, weight: .semibold))
        }
    }

    // MARK: 倍速 / 音量

    private var speedMenu: some View {
        Menu {
            ForEach(PlayerBarModel.speedOptions, id: \.self) { option in
                Button {
                    model.setSpeed(option)
                } label: {
                    if abs(model.speed - option) < 0.01 {
                        Label(speedText(option), systemImage: "checkmark")
                    } else {
                        Text(speedText(option))
                    }
                }
            }
        } label: {
            Text(speedText(model.speed))
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .frame(height: 22)
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("播放速度")
    }

    private func speedText(_ value: Float) -> String {
        String(format: "%g×", value)
    }

    private var volumeControl: some View {
        HStack(spacing: 5) {
            Button {
                model.toggleMute()
            } label: {
                Image(systemName: volumeIcon)
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 22, height: 22)
            }
            .help(model.isMuted ? "取消静音" : "静音")

            Slider(
                value: Binding(
                    get: { Double(model.isMuted ? 0 : model.volume) },
                    set: { model.setVolume(Float($0)) }
                ),
                in: 0...1
            )
            .controlSize(.mini)
            .tint(.white)
            .frame(width: 54)
        }
    }

    private var volumeIcon: String {
        if model.isMuted || model.volume <= 0 { return "speaker.slash.fill" }
        if model.volume < 0.34 { return "speaker.wave.1.fill" }
        if model.volume < 0.67 { return "speaker.wave.2.fill" }
        return "speaker.wave.3.fill"
    }

    // MARK: 画质

    private var qualityMenu: some View {
        Menu {
            ForEach(model.qualities) { quality in
                Button {
                    model.selectQuality(quality)
                } label: {
                    if quality.id == model.currentQualityId {
                        Label(quality.name, systemImage: "checkmark")
                    } else {
                        Text(quality.name)
                    }
                }
            }
        } label: {
            Text(currentQualityName ?? "画质")
                .font(.system(size: 11, weight: .semibold))
                .frame(height: 22)
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("清晰度")
    }

    private var currentQualityName: String? {
        guard let id = model.currentQualityId else { return nil }
        return model.qualities.first { $0.id == id }?.name
    }
}

// MARK: - 承载层

/// 挂在 `contentOverlayView` 里的控制栏宿主。
///
/// 职责：
/// 1. 底部居中摆放胶囊控制栏（约束让它在窄画面里自动压缩）；
/// 2. 鼠标移动/进出播放区 → 控制栏显隐；
/// 3. 画面区域双击 = 进出全屏（撤掉 AVKit 控件条后这颗手势由自绘层接管）。
final class PlayerControlsHostView: NSView {
    private let model: PlayerBarModel
    private let barView: NSHostingView<PlayerControlBar>
    private var trackingArea: NSTrackingArea?

    init(model: PlayerBarModel) {
        self.model = model
        self.barView = NSHostingView(rootView: PlayerControlBar(model: model))
        super.init(frame: .zero)

        barView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(barView)
        NSLayoutConstraint.activate([
            barView.centerXAnchor.constraint(equalTo: centerXAnchor),
            barView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            barView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 14),
            barView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),
            barView.widthAnchor.constraint(lessThanOrEqualToConstant: 680),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // mouseMoved 只有窗口接受鼠标移动事件时才会派发
        window?.acceptsMouseMovedEvents = true
    }

    override func layout() {
        super.layout()
        window?.acceptsMouseMovedEvents = true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseMoved(with event: NSEvent) {
        model.pokeActivity()
    }

    override func mouseEntered(with event: NSEvent) {
        model.pokeActivity()
    }

    override func mouseExited(with event: NSEvent) {
        model.mouseLeftPlayer()
    }

    override func mouseDown(with event: NSEvent) {
        // 画面区域双击进出全屏；控制栏上不触发
        if event.clickCount == 2, !isPointInBar(event.locationInWindow) {
            model.toggleFullscreen()
            return
        }
        super.mouseDown(with: event)
    }

    private func isPointInBar(_ windowPoint: NSPoint) -> Bool {
        barView.frame.contains(convert(windowPoint, from: nil))
    }
}
