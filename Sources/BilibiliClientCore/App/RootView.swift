#if os(macOS)
import AppKit
#endif
import SwiftUI

public struct UpRoute: Hashable {
    let mid: Int
}

public struct PartitionRoute: Hashable {
    let tid: Int
    let name: String
}

public struct SearchRoute: Hashable {
    let query: String
}

public struct DynamicRoute: Hashable {
    let id: String
}

public struct RootView: View {
    public init() {}

    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var router: AppRouter
    @AppStorage("appearance") private var appearance = AppearanceMode.system.rawValue
    @State private var selection: SidebarItem? = .dynamics
    @State private var showLogin = false
    @State private var showAccountPanel = false
    @State private var searchText = ""
    @State private var submittedQuery = ""

    enum SidebarItem: String, CaseIterable, Identifiable {
        case home = "推荐"
        case zones = "分区"
        case popular = "热门"
        case live = "直播"
        case dynamics = "动态"
        case favorites = "收藏"
        case history = "历史"
        case watchLater = "稍后再看"
        case settings = "设置"
        // 搜索仅由顶部搜索框进入，不出现在侧边栏
        case search = "搜索"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .zones: return "square.grid.2x2"
            case .popular: return "flame.fill"
            case .live: return "dot.radiowaves.left.and.right"
            case .dynamics: return "sparkles"
            case .favorites: return "bookmark"
            case .history: return "clock.arrow.circlepath"
            case .watchLater: return "clock.badge.checkmark"
            case .settings: return "gearshape"
            case .search: return "magnifyingglass"
            }
        }
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case AppearanceMode.light.rawValue: return .light
        case AppearanceMode.dark.rawValue: return .dark
        default: return nil
        }
    }

    public var body: some View {
        #if os(macOS)
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 190, ideal: 210, max: 270)
        } detail: {
            detailStack
        }
        .preferredColorScheme(colorScheme)
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .onAppear(perform: bindMainWindow)
        #else
        // iPhone 底部标签栏 / iPad 顶部标签栏，iPad 上可一键切到侧边栏（Apple Music 式）。
        // 分组用 SwiftUI 的 `TabSection`（嵌套 `Tab` 不被 SwiftUI 支持：Tab 只 conform
        // TabContent，不 conform View）。侧边栏里的「浏览 / 我的」分组与 macOS 侧边栏一致。
        TabView(selection: $selection) {
            TabSection("浏览") {
                Tab("动态", systemImage: SidebarItem.dynamics.icon, value: SidebarItem.dynamics) { tabStack(.dynamics) }
            }
            TabSection("我的") {
                Tab("收藏", systemImage: SidebarItem.favorites.icon, value: SidebarItem.favorites) { tabStack(.favorites) }
                Tab("历史", systemImage: SidebarItem.history.icon, value: SidebarItem.history) { tabStack(.history) }
                Tab("稍后再看", systemImage: SidebarItem.watchLater.icon, value: SidebarItem.watchLater) { tabStack(.watchLater) }
            }
            Tab("设置", systemImage: SidebarItem.settings.icon, value: SidebarItem.settings) { tabStack(.settings) }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSidebarFooter {
            accountBar
        }
        .searchable(text: $searchText, prompt: "搜索视频 / UP 主")
        .onSubmit(of: .search) { submitSearch() }
        .preferredColorScheme(colorScheme)
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        #endif
    }

    /// 详情区：macOS 与 iOS 共用同一套页面与导航目的地。
    private var detailStack: some View {
        NavigationStack(path: $router.path) {
            RootView.rootPage(for: selection, query: submittedQuery)
                .biliNavDestinations()
        }
    }

    #if os(iOS)
    /// 每个标签页一份**独立**导航栈。
    ///
    /// 千万别让多个标签页共用同一个 `$router.path`：那样推一个视频，
    /// 等于在每个已实例化的标签栈里各推一份，每份各建一个 `VideoDetailView` + 播放器，
    /// 于是「点进视频会同时播放好几个、暂停后后台还有一堆在响」。
    private func tabStack(_ item: SidebarItem) -> some View {
        TabNavStack(item: item, query: submittedQuery, isSelected: selection == item)
    }
    #endif

    #if os(macOS)
    /// 绑定主窗口代理，用于“关闭窗口”行为（完全退出 / 菜单栏模式 / 询问）。
    private func bindMainWindow() {
        let candidate = NSApp.windows.first { $0.identifier?.rawValue == "main" }
            ?? NSApp.windows.first { $0.isVisible && !($0 is NSPanel) }
        if let window = candidate {
            AppDelegate.shared?.adoptMainWindow(window)
            // macOS 会把窗口内第一个输入框（顶部搜索框）自动设为焦点，
            // 启动时清掉，避免键盘快捷键被搜索框吞掉
            DispatchQueue.main.async {
                window.makeFirstResponder(nil)
            }
        }
    }
    #endif

    private var sidebar: some View {
        List(selection: $selection) {
            Section("浏览") {
                ForEach(DeRecommendation.browseItems) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }
            Section("我的") {
                ForEach([SidebarItem.favorites, .history, .watchLater]) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }
            Section {
                Label(SidebarItem.settings.rawValue, systemImage: SidebarItem.settings.icon)
                    .tag(SidebarItem.settings)
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .top, spacing: 0) {
            GlassSearchField(text: $searchText) {
                submitSearch()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .safeAreaInset(edge: .bottom) { accountBar }
    }

    /// 侧边栏底部账户信息卡片：仅展示纯个人信息，点击可查看详情/退出登录。
    private var accountBar: some View {
        VStack(spacing: 0) {
            Divider()
            if session.loggedIn {
                Button {
                    showAccountPanel = true
                } label: {
                    HStack(spacing: 10) {
                        avatar(url: session.user?.face ?? "", size: 34)
                        Text(session.user?.name ?? "同步中…")
                            .font(.callout.weight(.medium))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    showLogin = true
                } label: {
                    Label("扫码登录", systemImage: "qrcode")
                        .font(.callout.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                }
                .buttonStyle(.borderedProminent)
                .padding(10)
            }
        }
        .popover(isPresented: $showAccountPanel, arrowEdge: .bottom) {
            AccountPanelView(showLogin: $showLogin)
                .environmentObject(session)
        }
    }

    private func submitSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedQuery = trimmed
        guard !trimmed.isEmpty else { return }
        #if os(macOS)
        selection = .search
        #else
        // iOS 的搜索不在标签栏里，直接推进导航栈（与点站内搜索结果同一条路径）
        router.path.append(SearchRoute(query: trimmed))
        #endif
    }

    private func avatar(url: String, size: CGFloat) -> some View {
        RemoteImage(url: Formatters.https(url), variant: .avatar)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

// MARK: - 导航栈共用件

extension RootView {
    /// 详情区的根页面。macOS 的单一导航栈与 iOS 的每个标签栈共用这一份。
    @ViewBuilder
    static func rootPage(for item: SidebarItem?, query: String) -> some View {
        switch item {
        case .home:
            RecommendView()
        case .zones:
            ZonesView()
        case .popular:
            PopularView()
        case .live:
            LiveFeedView()
        case .search:
            SearchView(query: query)
        case .dynamics:
            DynamicFeedView()
        case .favorites:
            FavoritesView()
        case .history:
            HistoryView()
        case .watchLater:
            WatchLaterView()
        case .settings:
            SettingsView()
        case nil:
            DynamicFeedView()
        }
    }
}

extension View {
    /// 全部导航目的地。两端、以及 iOS 的每个标签栈都挂同一套路由。
    func biliNavDestinations() -> some View {
        self
            .navigationDestination(for: String.self) { bvid in
                VideoDetailView(bvid: bvid)
            }
            .navigationDestination(for: UpRoute.self) { route in
                UpProfileView(mid: route.mid)
            }
            .navigationDestination(for: PartitionRoute.self) { route in
                PartitionVideosView(zone: BiliZone(id: route.tid, name: route.name, icon: "play.rectangle"))
            }
            .navigationDestination(for: SearchRoute.self) { route in
                SearchView(query: route.query)
            }
            .navigationDestination(for: DynamicRoute.self) { route in
                DynamicDetailView(id: route.id)
            }
            .navigationDestination(for: LiveRoute.self) { route in
                LiveDetailView(route: route)
            }
    }
}

#if os(iOS)
/// 单个标签页自己的导航栈。动机见 `RootView.tabStack(_:)` 的说明。
private struct TabNavStack: View {
    let item: RootView.SidebarItem
    let query: String
    let isSelected: Bool
    @EnvironmentObject private var router: AppRouter
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            RootView.rootPage(for: item, query: query)
                .biliNavDestinations()
        }
        // 外部程序化导航（搜索、评论里点视频、菜单栏卡片…）落进**当前**标签的栈。
        .onChange(of: router.path) { _, incoming in
            guard isSelected, incoming != path else { return }
            path = incoming
        }
        // 本栈变化时回写，让 `router.path` 始终等于当前可见标签的路径。
        .onChange(of: path) { _, outgoing in
            guard isSelected, outgoing != router.path else { return }
            router.path = outgoing
        }
    }
}
#endif
