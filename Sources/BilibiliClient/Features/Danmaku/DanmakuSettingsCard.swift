import SwiftUI

/// 播放页"弹幕设置"弹层：所有可调项集中在这里，改完立刻生效并持久化。
///
/// 与设置页共用同一批 `@AppStorage` 键，所以两处永远一致。
struct DanmakuSettingsCard: View {
    @AppStorage("danmakuEnabled") private var enabled = true
    @AppStorage("danmakuSpeed") private var speed = DanmakuSpeed.normal.rawValue
    @AppStorage("danmakuOpacity") private var opacity = DanmakuSettings.default.opacity
    @AppStorage("danmakuFontScale") private var fontScale = DanmakuSettings.default.fontScale
    @AppStorage("danmakuFullscreenScale") private var fullscreenScale = DanmakuSettings.default.fullscreenScale
    @AppStorage("danmakuDisplayArea") private var displayArea = DanmakuSettings.default.displayArea.rawValue
    @AppStorage("danmakuShowsFloating") private var showsFloating = DanmakuSettings.default.showsFloating
    @AppStorage("danmakuShowsTop") private var showsTop = DanmakuSettings.default.showsTop
    @AppStorage("danmakuShowsBottom") private var showsBottom = DanmakuSettings.default.showsBottom
    @AppStorage("danmakuAllowsOverlap") private var allowsOverlap = DanmakuSettings.default.allowsOverlap

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("弹幕设置", systemImage: "text.bubble")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $enabled)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .labelsHidden()
                    .help(enabled ? "关闭弹幕" : "开启弹幕")
            }

            Divider()

            sliderRow("不透明度",
                      value: $opacity,
                      range: DanmakuSettings.opacityRange,
                      text: "\(Int((opacity * 100).rounded()))%")

            sliderRow("字号",
                      value: $fontScale,
                      range: DanmakuSettings.fontScaleRange,
                      text: "\(Int((fontScale * 100).rounded()))%")

            sliderRow("全屏跟随",
                      value: $fullscreenScale,
                      range: DanmakuSettings.fullscreenScaleRange,
                      text: "\(Int((fullscreenScale * 100).rounded()))%")
                .help("全屏时弹幕只按该比例跟随画面放大：100% 即与画面同比例，调小则全屏弹幕更小")

            row("显示区域") {
                Picker("", selection: $displayArea) {
                    ForEach(DanmakuDisplayArea.allCases) { area in
                        Text(area.label).tag(area.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 196)
                .help("弹幕占画面高度的比例，调小可以避开人脸与字幕")
            }

            row("速度") {
                Picker("", selection: $speed) {
                    ForEach(DanmakuSpeed.allCases) { item in
                        Text(item.label).tag(item.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 196)
                .help("滚动弹幕横穿屏幕的时长")
            }

            Divider()

            row("显示类型") {
                HStack(spacing: 10) {
                    typeToggle("滚动", isOn: $showsFloating)
                    typeToggle("顶部", isOn: $showsTop)
                    typeToggle("底部", isOn: $showsBottom)
                }
            }

            row("允许重叠") {
                Toggle("", isOn: $allowsOverlap)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .labelsHidden()
                    .help("关闭时同轨道弹幕不会互相压住，画面更整齐")
            }
        }
        .padding(16)
        .frame(width: 348)
    }

    // MARK: - 行样式

    private func row<Content: View>(_ title: String,
                                    @ViewBuilder control: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(.callout)
            Spacer(minLength: 12)
            control()
        }
    }

    private func sliderRow(_ title: String,
                           value: Binding<Double>,
                           range: ClosedRange<Double>,
                           text: String) -> some View {
        row(title) {
            HStack(spacing: 8) {
                Slider(value: value, in: range)
                    .frame(width: 140)
                Text(text)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 42, alignment: .trailing)
            }
        }
    }

    private func typeToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(.checkbox)
            .font(.callout)
    }
}
