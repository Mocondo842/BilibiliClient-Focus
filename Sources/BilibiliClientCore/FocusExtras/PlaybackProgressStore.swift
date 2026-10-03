import Foundation

/// 本 fork 新增：本地播放进度。
///
/// 上游只把进度上报给 B 站（HistoryReporter），本地不留；于是「从历史记录进入」
/// 或「切换清晰度重建播放器」都会从头播。这里按 (bvid, cid) 存一份本地进度，
/// 由 PlayerController 在首次加载与重建后恢复、在播放中与退出时写回。
enum PlaybackProgressStore {
    private static let prefix = "playbackProgress."
    private static let indexKey = "playbackProgress.index"
    /// 最多保留多少条进度，避免 UserDefaults 无限膨胀。
    private static let maxEntries = 200
    /// 小于这个秒数不值得续播（也避免刚点开就 seek）。
    private static let minimumSeconds: Double = 5

    private static func key(bvid: String, cid: Int) -> String { "\(prefix)\(bvid).\(cid)" }

    /// 该视频上次看到的位置；没有或太短则返回 nil。
    static func position(bvid: String, cid: Int) -> Double? {
        guard !bvid.isEmpty else { return nil }
        let value = UserDefaults.standard.double(forKey: key(bvid: bvid, cid: cid))
        return value >= minimumSeconds ? value : nil
    }

    static func save(_ seconds: Double, bvid: String, cid: Int) {
        guard !bvid.isEmpty, seconds.isFinite, seconds >= minimumSeconds else { return }
        let defaults = UserDefaults.standard
        defaults.set(seconds, forKey: key(bvid: bvid, cid: cid))
        var index = defaults.stringArray(forKey: indexKey) ?? []
        let entry = key(bvid: bvid, cid: cid)
        index.removeAll { $0 == entry }
        index.append(entry)
        while index.count > maxEntries {
            let dropped = index.removeFirst()
            defaults.removeObject(forKey: dropped)
        }
        defaults.set(index, forKey: indexKey)
    }

    /// 看完（或从头重看）时清掉，避免下次进来又跳回结尾。
    static func clear(bvid: String, cid: Int) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key(bvid: bvid, cid: cid))
        var index = defaults.stringArray(forKey: indexKey) ?? []
        index.removeAll { $0 == key(bvid: bvid, cid: cid) }
        defaults.set(index, forKey: indexKey)
    }

    /// 进度百分比（0...1），给列表显示用；没有记录返回 nil。
    static func fraction(bvid: String, cid: Int, duration: Double) -> Double? {
        guard duration > 0, let position = position(bvid: bvid, cid: cid) else { return nil }
        return min(max(position / duration, 0), 1)
    }
}
