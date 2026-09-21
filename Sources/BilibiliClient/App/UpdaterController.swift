import Foundation
import Sparkle

/// 自动更新（Sparkle）。
///
/// 工作方式：App 内嵌 Sparkle，按 Info.plist 的 `SUFeedURL` 拉 appcast（HTTPS），
/// 对比 `CFBundleVersion`（本项目用 git 提交数，天然单调递增），有新版本就下载 zip、
/// 用 `SUPublicEDKey` 校验 EdDSA 签名、再校验新 App 的代码签名，然后就地替换并重启。
///
/// 发布侧流程见 `scripts/release.sh`（打包 → generate_appcast 签名 → 上传 GitHub Release）。
@MainActor
final class UpdaterController {
    static let shared = UpdaterController()

    private let controller: SPUStandardUpdaterController

    private init() {
        // startingUpdater: true —— 启动即按 Info.plist 的 SUEnableAutomaticChecks 定时检查
        controller = SPUStandardUpdaterController(startingUpdater: true,
                                                  updaterDelegate: nil,
                                                  userDriverDelegate: nil)
    }

    private var updater: SPUUpdater { controller.updater }

    /// 当前是否可以手动检查（正在检查/下载时为 false）
    var canCheckForUpdates: Bool { updater.canCheckForUpdates }

    /// 弹 Sparkle 的标准更新窗（含发布说明、进度、重启按钮）
    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }

    /// 自动检查更新（写入 Sparkle 自己的偏好，与它的设置界面共享）
    var automaticallyChecksForUpdates: Bool {
        get { updater.automaticallyChecksForUpdates }
        set { updater.automaticallyChecksForUpdates = newValue }
    }

    /// 自动下载并安装（静默更新），需要先打开自动检查
    var automaticallyDownloadsUpdates: Bool {
        get { updater.automaticallyDownloadsUpdates }
        set { updater.automaticallyDownloadsUpdates = newValue }
    }

    /// 上次检查时间（设置页展示用）
    var lastUpdateCheckDate: Date? { updater.lastUpdateCheckDate }
}
