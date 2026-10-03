import Foundation

/// 本 fork 新增：登录 cookie 的**兜底**存储。
///
/// 上游把 cookie 存在钥匙串里（`KeychainStore`），而钥匙串条目的访问权限绑在**代码签名**上：
/// ad-hoc 签名（CI 产物就是）的「设计要求」是 cdhash，每次构建都不同；Gatekeeper 还会把
/// 从网上下载来的 App 放到随机只读路径运行。两者叠加的后果是「上一份构建写进去的条目
/// 读不回来」——表现就是每次打开 App 都要重新登录。
///
/// 因此：钥匙串**能用就不落盘**；只有在钥匙串读写失败时才退化为 0600 权限的本地文件
/// （只存登录 cookie，和浏览器把 cookie 存进用户目录同级）。
enum SessionFallbackStore {
    private static var fileURL: URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = base.appendingPathComponent("BilibiliClient", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("session.json")
    }

    static func save(_ cookies: BiliCookies) {
        guard let url = fileURL, let data = try? JSONEncoder().encode(cookies) else { return }
        try? data.write(to: url, options: [.atomic])
        try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }

    static func load() -> BiliCookies? {
        guard let url = fileURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(BiliCookies.self, from: data)
    }

    static func delete() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
