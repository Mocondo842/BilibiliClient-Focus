import Foundation

/// 弹幕显示区域档位（弹幕占画面高度的比例）
enum DanmakuDisplayArea: Double, CaseIterable, Identifiable {
    case quarter = 0.25
    case half = 0.5
    case threeQuarters = 0.75
    case full = 1

    var id: Double { rawValue }

    var label: String {
        switch self {
        case .quarter: return "1/4"
        case .half: return "1/2"
        case .threeQuarters: return "3/4"
        case .full: return "全屏"
        }
    }
}

/// 弹幕外观 / 行为设置。
///
/// 持久化在 `UserDefaults`（`@AppStorage` 用的同一批键），播放页的"弹幕设置"卡片
/// 与设置页读写的是同一份值，改完立刻生效、下次启动仍然保留。
struct DanmakuSettings: Equatable {
    var opacity: Double
    var fontScale: Double
    /// 全屏（画面变大）时弹幕自己的放大比例：1 = 与画面同比例，< 1 = 只长一部分。
    /// 实现上是 1 + (画面倍数 - 1) × 该比例，所以在屏与过渡中都是连续的。
    var fullscreenScale: Double
    var displayArea: DanmakuDisplayArea
    var showsFloating: Bool
    var showsTop: Bool
    var showsBottom: Bool
    var allowsOverlap: Bool

    static let opacityRange: ClosedRange<Double> = 0.2...1
    static let fontScaleRange: ClosedRange<Double> = 0.6...1.6
    static let fullscreenScaleRange: ClosedRange<Double> = 0.5...1

    /// 默认值（也是各 `@AppStorage` 的默认值）
    static let `default` = DanmakuSettings(opacity: 1,
                                           fontScale: 1,
                                           fullscreenScale: 0.8,
                                           displayArea: .full,
                                           showsFloating: true,
                                           showsTop: true,
                                           showsBottom: true,
                                           allowsOverlap: false)

    /// 从 UserDefaults 读当前设置（非 UI 调用方用，比如渲染层初始化）
    static var current: DanmakuSettings {
        let store = UserDefaults.standard
        func double(_ key: String, _ fallback: Double) -> Double {
            store.object(forKey: key) == nil ? fallback : store.double(forKey: key)
        }
        func flag(_ key: String, _ fallback: Bool) -> Bool {
            store.object(forKey: key) == nil ? fallback : store.bool(forKey: key)
        }
        return DanmakuSettings(
            opacity: min(max(double("danmakuOpacity", Self.default.opacity),
                             Self.opacityRange.lowerBound), Self.opacityRange.upperBound),
            fontScale: min(max(double("danmakuFontScale", Self.default.fontScale),
                               Self.fontScaleRange.lowerBound), Self.fontScaleRange.upperBound),
            fullscreenScale: min(max(double("danmakuFullscreenScale", Self.default.fullscreenScale),
                                     Self.fullscreenScaleRange.lowerBound),
                                 Self.fullscreenScaleRange.upperBound),
            displayArea: DanmakuDisplayArea(rawValue: double("danmakuDisplayArea", Self.default.displayArea.rawValue))
                ?? Self.default.displayArea,
            showsFloating: flag("danmakuShowsFloating", Self.default.showsFloating),
            showsTop: flag("danmakuShowsTop", Self.default.showsTop),
            showsBottom: flag("danmakuShowsBottom", Self.default.showsBottom),
            allowsOverlap: flag("danmakuAllowsOverlap", Self.default.allowsOverlap)
        )
    }
}
