# 仓库约定（请遵守）

## 版本号
- **每次提交都自动升 `version.txt`**，不用再等确认。
- **默认只升修订号，保持在当前次版本内**（1.7.2 → 1.7.3 → 1.7.4…）。
  要开新次版本号（1.7.x → 1.8.0）必须由用户明确要求，不要自作主张跳次版本。
- 版本号写进提交信息末尾，形如 `（v1.7.3）`。
- **打 tag 与对外发布仍然要等用户确认**：发版跑
  `./scripts/release.sh <version> --publish`（打 zip、EdDSA 签名、上传 GitHub Release、刷新 `docs/appcast.xml`）。
- 需要给某一版留档时用 `git tag -f` 把 tag 指到最终的修复提交即可。

## 构建与验证
- **每次改完代码都要自动打包一次 `.app`**（用户明确要求，不用等确认）：
  跑 `./scripts/build_app.sh release`，产出 `dist/BilibiliClient.app` 并自动打开。
  **不要**习惯性加 `NO_OPEN=1` —— 那会跳过打开，用户就看不到新构建。
- 改动触及共享层 `BilibiliClientCore`（绝大多数改动）时，顺带跑一次
  `./scripts/build_ios_app.sh --simulator debug` 验证 iOS 侧没被编译坏。
- 构建：`./scripts/build_app.sh release`（写入 `dist/`、杀掉旧进程并自动打开 App）。
  确有需要（比如脚本化验证、不想被抢焦点）才用 `NO_OPEN=1 ./scripts/build_app.sh release`。
- 默认**不再**往 `dist/archive/` 堆历史 `.app`：每个版本都能从 tag 重建（见「回退」），
  正式发布由 GitHub Releases 留存，本地只保留 `dist/BilibiliClient.app` 这一份最新构建。
  确实需要本地留档时用 `KEEP_ARCHIVE=1 ./scripts/build_app.sh release`。
- 版本号单点来源是 `version.txt`，`BuildInfo.generated.swift` 由脚本生成，不要手改。
- 改动弹幕 / 播放相关逻辑时，至少实测一次「进入全屏 → 退出全屏」的过渡。

## 回退
- 每个版本都有 tag（`git tag`），回退 = 检出 tag 再重建：
  `git checkout vX.Y.Z && NO_OPEN=1 ./scripts/build_app.sh release`。
- 从 tag 重建会覆写受版本控制的 `BuildInfo.generated.swift`，切回主线时用 `git checkout -f main`。
