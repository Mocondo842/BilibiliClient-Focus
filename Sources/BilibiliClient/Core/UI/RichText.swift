import SwiftUI
import Textual

/// B 站正文解析器（Textual 的 `MarkupParser`）。
///
/// 把正文里的**链接 / BV 号 / @提及 / #话题#** 识别出来并套上样式：
/// 链接变成可点的 `.link`（走系统 openURL），@ 与 # 用强调色标出，其余原样保留。
/// 不做 Markdown 解析——B 站正文不是 Markdown，走 Markdown 会把 `*`、`_` 这类字符吃掉。
struct BilibiliTextParser: MarkupParser {
    var linkColor: Color = .accentColor
    var mentionColor: Color = .accentColor
    var topicColor: Color = .accentColor

    /// 依次匹配：链接/BV 号、@提及、#话题#
    private static let pattern = #"(https?://[^\s]+|www\.[^\s]+|BV[0-9A-Za-z]{10})|(@[^\s@#，。！？；：、）】]+)|(#(?:[^#\s][^#\n]{0,38})#)"#

    func attributedString(for input: String) throws -> AttributedString {
        let regex = try NSRegularExpression(pattern: Self.pattern)
        let source = input as NSString
        var result = AttributedString()
        var cursor = 0

        for match in regex.matches(in: input, range: NSRange(location: 0, length: source.length)) {
            if match.range.location > cursor {
                result += AttributedString(source.substring(with: NSRange(location: cursor,
                                                                        length: match.range.location - cursor)))
            }
            let token = source.substring(with: match.range)
            var piece = AttributedString(token)
            if match.range(at: 2).location != NSNotFound {
                piece.foregroundColor = mentionColor
            } else if match.range(at: 3).location != NSNotFound {
                piece.foregroundColor = topicColor
            } else {
                piece.foregroundColor = linkColor
                piece.underlineStyle = .single
                piece.link = Self.link(for: token)
            }
            result += piece
            cursor = match.range.location + match.range.length
        }

        if cursor < source.length {
            result += AttributedString(source.substring(from: cursor))
        }
        return result
    }

    private static func link(for token: String) -> URL? {
        if token.hasPrefix("BV") {
            return URL(string: "https://www.bilibili.com/video/\(token)")
        }
        return URL(string: token.hasPrefix("www.") ? "https://\(token)" : token)
    }
}

/// 富文本正文（Textual 渲染）。
///
/// 相比裸 `Text`：链接可点、@/# 有样式、文本可选中，多行与 `lineLimit` 行为与 `Text` 一致。
struct RichText: View {
    let text: String
    var font: Font = .callout
    var lineSpacing: CGFloat?
    var selectable = true

    var body: some View {
        InlineText(text, parser: BilibiliTextParser())
            .font(font)
            .lineSpacing(lineSpacing ?? 0)
            .modifier(RichTextSelection(selectable: selectable))
    }
}

private struct RichTextSelection: ViewModifier {
    let selectable: Bool

    func body(content: Content) -> some View {
        if selectable {
            content.textual.textSelection(.enabled)
        } else {
            content.textual.textSelection(.disabled)
        }
    }
}
