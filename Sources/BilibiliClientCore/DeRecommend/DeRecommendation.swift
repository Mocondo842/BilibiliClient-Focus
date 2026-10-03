import Foundation

/// 本 fork 的去推荐化补丁：界面上只保留「主动关注」与「主动检索」两类内容。
///
/// 合并纪律见仓库根目录 `FORK.md`：本文件承载全部下游逻辑，
/// 上游文件只允许出现「导航清单」与「动态条目过滤」两种锚点改动。
enum DeRecommendation {
    /// 侧边栏 / iOS 标签栏「浏览」区可见的条目：只留关注流（动态）。
    /// 分区排行榜是边界项（FORK.md「边界项 B1」），默认一并摘除。
    static let browseItems: [RootView.SidebarItem] = [.dynamics]

    /// 确认由官方注入、不属于「你关注的人发布的内容」的动态类型。
    ///
    /// 依据社区 API 文档的动态类型对照（bilibili-API-collect `docs/dynamic/dynamic_enum.md`）：
    /// - `DYNAMIC_TYPE_LIVE_RCMD` = 直播开播（推荐直播）
    /// - `DYNAMIC_TYPE_AD` = 广告
    /// - `DYNAMIC_TYPE_BANNER` = 横幅
    /// - `MAJOR_TYPE_LIVE_RCMD` = 直播状态：它是 `moduleDynamic.major` 的取值，
    ///   所以这类条目**带** `moduleDynamic`，只靠下面的兜底判据拦不住。
    ///
    /// 边界项 B2（默认**不**拦，见 `FORK.md`）：`DYNAMIC_TYPE_APPLET`（小程序）、
    /// `DYNAMIC_TYPE_SUBSCRIPTION` / `_NEW`（订阅、追更）——文档里它们的说明为空，
    /// 无法证明只由官方注入；而「订阅」更像你自己的订阅行为，误杀会丢关注内容。
    /// 实机确认是官方推广后，把类型名加进本表即可（一行）。
    private static let blockedItemTypes: Set<String> = [
        "DYNAMIC_TYPE_LIVE_RCMD",
        "DYNAMIC_TYPE_AD",
        "DYNAMIC_TYPE_BANNER",
    ]
    private static let blockedMajorTypes: Set<String> = [
        "MAJOR_TYPE_LIVE_RCMD",
    ]

    /// 动态流条目是否保留（只保留关注来源的内容）。
    ///
    /// 两道判据：
    /// 1) 黑名单：上表列出的官方注入类型一律丢弃（`item.type` 与 `major.type` 各查一次）；
    /// 2) 兜底：其余条目必须带正文模块（`modules.moduleDynamic`）或转发原文（`orig`）。
    ///    两者皆无的条目，上游 `DynamicCardView` 取不到任何正文——`dynamicText` 只读
    ///    `moduleDynamic.desc` 与 `opus.summary`，`majorContent` 的 `default` 是 `EmptyView`
    ///    （`DynamicFeedView.swift:293-330`）——只会留下一张只有头像和计数的空卡片。
    ///    判据 2 的边界要说清：带 `moduleDynamic` 但 major 不被上游渲染的条目**不会**被它丢弃，
    ///    这类条目要么进黑名单，要么留给 `FORK.md` 的实机核对项（§9 V2）处置。
    static func keeps(_ item: DynamicItem) -> Bool {
        if blockedItemTypes.contains(item.type) { return false }
        if let major = item.modules.moduleDynamic?.major, blockedMajorTypes.contains(major.type) { return false }
        return item.modules.moduleDynamic != nil || item.orig != nil
    }
}

extension Array where Element == DynamicItem {
    /// 只保留关注来源的动态。
    var followOnly: [DynamicItem] { filter(DeRecommendation.keeps) }
}
