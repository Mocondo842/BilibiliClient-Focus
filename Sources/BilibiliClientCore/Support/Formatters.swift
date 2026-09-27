import Foundation

enum Formatters {
    static func count(_ value: Int) -> String {
        if value >= 100_000_000 {
            return decimal(Double(value) / 100_000_000) + "亿"
        }
        if value >= 10_000 {
            return decimal(Double(value) / 10_000) + "万"
        }
        return "\(value)"
    }

    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return "\(h):\(two(m)):\(two(s))"
        }
        return "\(two(m)):\(two(s))"
    }

    /// 把 "hh:mm:ss" / "mm:ss" 时长文本转成秒数（搜索接口返回的是文本）。
    static func seconds(fromDurationText text: String?) -> Int {
        guard let text, !text.isEmpty else { return 0 }
        let parts = text.split(separator: ":").compactMap { Int($0) }
        guard !parts.isEmpty else { return 0 }
        return parts.reduce(0) { $0 * 60 + $1 }
    }

    static func https(_ url: String) -> URL? {
        var value = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("//") {
            // 协议相对地址，如 //i0.hdslb.com/xxx.jpg
            value = "https:" + value
        } else if value.hasPrefix("http://") {
            value = "https://" + value.dropFirst("http://".count)
        }
        return URL(string: value)
    }

    // MARK: - 图床尺寸后缀

    /// 图片用途：决定向 B 站图床请求多大的图（服务端缩好再下发）。
    enum ImageVariant {
        /// 头像（正方形）
        case avatar
        /// 16:9 封面（列表卡片、直播封面）
        case card
        /// 大图 16:9（播放页、详情页大图）
        case detail
        /// 宽高比不确定的图（动态配图）：只约束宽度、不裁剪
        case keepAspect

        var suffix: String? {
            switch self {
            case .avatar: return "@144w_144h_1c.webp"
            case .card: return "@672w_378h_1c.webp"
            case .detail: return "@1280w_720h_1c.webp"
            case .keepAspect: return "@960w.webp"
            }
        }
    }

    /// 给 B 站图床（*.hdslb.com）的地址加上尺寸/格式后缀。
    ///
    /// 服务端会直接返回缩好的 WebP：实测热门封面 395KB → 26KB（省 93%）、
    /// 头像 60KB → 2.8KB，解码后的内存也小一个数量级。
    /// 非图床域名、或地址本身已经带后缀时原样返回。
    static func sized(_ url: URL?, _ variant: ImageVariant) -> URL? {
        guard let url, let suffix = variant.suffix else { return url }
        guard let host = url.host?.lowercased(), host.hasSuffix("hdslb.com") else { return url }
        // 动图不转静态 WebP（后缀会把 gif 变成一张静帧）
        guard !url.path.lowercased().hasSuffix(".gif") else { return url }
        var text = url.absoluteString
        // 已经带过 @ 后缀（如接口返回的 @320w）就不要重复拼
        if let mark = text.lastIndex(of: "@"), !text[text.index(after: mark)...].isEmpty {
            return url
        }
        if let queryStart = text.firstIndex(of: "?") {
            text.insert(contentsOf: suffix, at: queryStart)
        } else {
            text += suffix
        }
        return URL(string: text) ?? url
    }

    /// 定点小数格式化（规避部分环境下 String(format:) 失效的问题）。
    static func decimal(_ value: Double, fractionDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// 相对时间："刚刚 / x 分钟前 / x 小时前 / x 天前 / yyyy-MM-dd"
    static func timeAgo(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "刚刚" }
        if interval < 3600 { return "\(Int(interval / 60)) 分钟前" }
        if interval < 86_400 { return "\(Int(interval / 3600)) 小时前" }
        if interval < 86_400 * 30 { return "\(Int(interval / 86_400)) 天前" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func two(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
