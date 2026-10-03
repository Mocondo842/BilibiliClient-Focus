import Foundation

@MainActor
public final class SessionStore: ObservableObject {
    /// 全局共享实例：主界面与菜单栏卡片共用同一登录状态。
    public static let shared = SessionStore()

    @Published var loggedIn = false
    @Published var user: UserProfile?

    private(set) var cookies = BiliCookies()

    struct UserProfile {
        let mid: Int
        let name: String
        let face: String
        let level: Int
        let following: Int
        let follower: Int
        let coin: Double
    }

    init() {
        if let saved = KeychainStore.load() {
            adopt(saved)
        } else if let fallback = SessionFallbackStore.load() {
            // 钥匙串读不回来（ad-hoc 签名 / Gatekeeper 随机路径）时用文件兜底，并尝试迁回钥匙串。
            adopt(fallback)
            KeychainStore.save(fallback)
        }
        if loggedIn {
            Task { await refreshUser() }
        }
    }

    /// 把一份 cookie 装载成当前会话状态。
    private func adopt(_ saved: BiliCookies) {
        cookies = saved
        loggedIn = !saved.isEmpty
        APIClient.shared.cookieHeader = saved.headerValue
        APIClient.shared.cookies = saved
    }

    func apply(cookies: BiliCookies) {
        self.cookies = cookies
        loggedIn = !cookies.isEmpty
        APIClient.shared.cookieHeader = cookies.headerValue
        APIClient.shared.cookies = cookies
        KeychainStore.save(cookies)
        // 钥匙串写得进就不落盘；写不进（无稳定签名）才退化为 0600 文件。
        if !cookies.isEmpty, KeychainStore.load() == nil {
            SessionFallbackStore.save(cookies)
        } else {
            SessionFallbackStore.delete()
        }
        Task { await refreshUser() }
    }

    func refreshUser() async {
        do {
            struct NavStat: Decodable {
                let following: Int
                let follower: Int
            }

            async let navResult: NavData = APIClient.shared.get("/x/web-interface/nav")
            async let statResult: NavStat = APIClient.shared.get("/x/web-interface/nav/stat")
            let (nav, stat) = try await (navResult, statResult)
            guard let mid = nav.mid, let name = nav.uname else { return }
            user = UserProfile(
                mid: mid,
                name: name,
                face: nav.face ?? "",
                level: nav.levelInfo?.currentLevel ?? 0,
                following: stat.following,
                follower: stat.follower,
                coin: nav.money ?? 0
            )
        } catch {
            // 保持已有用户信息，静默失败
        }
    }

    func logout() {
        KeychainStore.delete()
        SessionFallbackStore.delete()
        cookies = BiliCookies()
        user = nil
        loggedIn = false
        APIClient.shared.cookieHeader = ""
        APIClient.shared.cookies = BiliCookies()
    }
}
