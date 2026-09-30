import SwiftUI

/// 画面上的空降提示：「已跳过赞助广告 · 18 秒」，可点一下回退。
///
/// 样式与左上角的「在线人数」徽标同一套（胶囊 + 液态玻璃），
/// 因此挂在画面右上角，两者不打架。
struct SponsorNoticeBadge: View {
    let notice: SponsorNotice
    /// 点「回退」时的回调；nil 表示这条提示不可交互。
    var onUndo: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme
    @State private var hovering = false

    private var canUndo: Bool { notice.isUndoable && onUndo != nil }

    var body: some View {
        Group {
            if canUndo {
                Button {
                    onUndo?()
                } label: {
                    capsule
                }
                .buttonStyle(.plain)
                .onHover { inside in
                    guard inside != hovering else { return }
                    hovering = inside
                    AppPlatform.setPointingHandCursor(inside)
                }
                // 提示是定时消失的：鼠标还悬在上面时整条被移除，
                // 不会再有 onHover(false)，这里必须自己把光标还回去
                .onDisappear {
                    guard hovering else { return }
                    hovering = false
                    AppPlatform.setPointingHandCursor(false)
                }
                .help("回到这段广告的开头，并且之后不再自动跳过它")
            } else {
                capsule
            }
        }
    }

    private var capsule: some View {
        HStack(spacing: 6) {
            Image(systemName: notice.symbolName)
                .font(.system(size: 10, weight: .semibold))

            Text(notice.text)
                .font(.caption.weight(.medium))
                .monospacedDigit()

            if canUndo {
                Rectangle()
                    .fill(.primary.opacity(0.2))
                    .frame(width: 1, height: 10)

                HStack(spacing: 3) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 9, weight: .semibold))
                    Text("回退")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(Color.accentColor)
            }
        }
        .foregroundStyle(Color.primary.opacity(0.9))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(fillColor)
                .overlay {
                    Capsule()
                        .stroke(.primary.opacity(canUndo && hovering ? 0.35 : 0.15), lineWidth: 1)
                        .glassEffect(.regular, in: .capsule)
                }
        }
        .contentShape(Capsule())
        // 不可回退的提示只是通知，不该拦住画面上的点击
        .allowsHitTesting(canUndo)
    }

    private var fillColor: Color {
        let base: Color = colorScheme == .dark ? .black : .white
        let opacity = canUndo && hovering ? 0.5 : 0.25
        return base.opacity(opacity)
    }
}
