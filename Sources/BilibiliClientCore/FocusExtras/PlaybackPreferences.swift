import Foundation

/// 本 fork 新增：播放偏好（优先清晰度 / 优先编码）与评论字号。
/// 值都存在 UserDefaults，与设置页的 @AppStorage 共用同一批 key。
enum PlaybackPreferences {
    // MARK: - 优先清晰度

    enum QualityChoice: Int, CaseIterable, Identifiable {
        case p720 = 64
        case p1080 = 80
        case p1080_60 = 116
        case p1080Plus = 112
        case p4K = 120
        case p8K = 127

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .p720: return "720P"
            case .p1080: return "1080P（默认）"
            case .p1080_60: return "1080P 60帧"
            case .p1080Plus: return "1080P 高码率"
            case .p4K: return "4K"
            case .p8K: return "8K"
            }
        }
    }

    static let qualityKey = "preferredQualityId"

    /// 首次加载用的清晰度；未设置时保持上游行为（80 = 1080P）。
    static var initialQuality: Int {
        let stored = UserDefaults.standard.integer(forKey: qualityKey)
        return stored > 0 ? stored : 80
    }

    // MARK: - 优先编码

    enum Codec: String, CaseIterable, Identifiable {
        case auto, avc, hevc, av1

        var id: String { rawValue }

        var label: String {
            switch self {
            case .auto: return "自动（优先 H.264）"
            case .avc: return "H.264 / AVC"
            case .hevc: return "H.265 / HEVC"
            case .av1: return "AV1"
            }
        }

        /// 匹配 `PlayURLData.DashStream.codecs` 前缀，例如 avc1.640032 / hev1.1.6 / av01.0.08M。
        func matches(_ codecs: String?) -> Bool {
            guard let codecs = codecs?.lowercased() else { return false }
            switch self {
            case .auto, .avc: return codecs.hasPrefix("avc1")
            case .hevc: return codecs.hasPrefix("hev1") || codecs.hasPrefix("hvc1")
            case .av1: return codecs.hasPrefix("av01")
            }
        }
    }

    static let codecKey = "preferredCodec"

    static var preferredCodec: Codec {
        Codec(rawValue: UserDefaults.standard.string(forKey: codecKey) ?? "") ?? .auto
    }

    /// 按偏好挑候选流：先偏好的编码，再退到 H.264，最后任意。
    /// 上游原本写死"有 AVC 就用 AVC"，这里把"用哪种编码"变成可配置。
    static func preferredStreams(_ streams: [PlayURLData.DashStream]) -> [PlayURLData.DashStream] {
        let wanted = preferredCodec
        let preferred = streams.filter { wanted.matches($0.codecs) }
        if !preferred.isEmpty { return preferred }
        let avc = streams.filter { Codec.avc.matches($0.codecs) }
        return avc.isEmpty ? streams : avc
    }

    // MARK: - 评论字号

    enum CommentFontSize: String, CaseIterable, Identifiable {
        case system, small, medium, large, xLarge

        var id: String { rawValue }

        var label: String {
            switch self {
            case .system: return "跟随系统"
            case .small: return "小"
            case .medium: return "标准"
            case .large: return "大"
            case .xLarge: return "特大"
            }
        }

        /// 相对基准字号的倍率；`.system` 返回 nil 表示不改字号（保持上游语义字体）。
        var scale: CGFloat? {
            switch self {
            case .system: return nil
            case .small: return 0.9
            case .medium: return 1.0
            case .large: return 1.15
            case .xLarge: return 1.3
            }
        }
    }

    static let commentFontSizeKey = "commentFontSize"

    static var commentFontSize: CommentFontSize {
        CommentFontSize(rawValue: UserDefaults.standard.string(forKey: commentFontSizeKey) ?? "") ?? .system
    }
}
