import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// 评论字号：默认（`.system`）完全沿用上游的语义字体，只有用户显式选了档位才缩放，
/// 因此不动设置时视觉与上游一致。
enum CommentFonts {
    /// 取系统语义字体的真实字号，避免自己猜 pt 导致与上游不一致。
    private static func baseSize(_ style: Font.TextStyle) -> CGFloat {
        #if os(macOS)
        return NSFont.preferredFont(forTextStyle: style.nsTextStyle).pointSize
        #else
        return UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        #endif
    }

    static func font(_ style: Font.TextStyle) -> Font {
        guard let scale = PlaybackPreferences.commentFontSize.scale else {
            return Font.system(style)
        }
        return .system(size: baseSize(style) * scale)
    }

    static var callout: Font { font(.callout) }
    static var caption: Font { font(.caption) }
    static var caption2: Font { font(.caption2) }
    static var subheadline: Font { font(.subheadline) }
}

#if os(macOS)
private extension Font.TextStyle {
    var nsTextStyle: NSFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
#else
private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
#endif
