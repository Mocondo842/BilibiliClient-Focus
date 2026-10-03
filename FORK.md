# FORK.md —— 本分支（去推荐化）的合并纪律

- 上游：`Mora-han/BilibiliClient`（本 fork 的 parent），远端名 `upstream`（只读）
- 本分支：`derec-layout`（只保留主动关注与主动检索的界面）；`main` 保持与上游一致，随时可快进
- 定稿方案：六轮交叉评审第 6 轮判定合格（strict），见评审目录 `cross-review/bilibili-client-derec/`

## 这个分支做了什么

1. 侧边栏 / iOS 标签栏的「浏览」区只剩「动态」（关注流）；默认落地页与空选中回落都指向动态。
2. 动态流与菜单栏面板过滤掉官方注入条目：文档化黑名单（`DYNAMIC_TYPE_LIVE_RCMD` / `AD` / `BANNER`，以及 major 级 `MAJOR_TYPE_LIVE_RCMD`）+ 空条目兜底（不带 `moduleDynamic` 也不带 `orig` 的条目上游本来也渲染不出正文）。
3. `scripts/build_app.sh` 的 Sparkle 默认 feed 改指本分支自己的 appcast。不改的话，`CFBundleVersion`（= git 提交数）会被上游 release 反超，App 自动更新回官方版并把本补丁抹掉。

## 改动面预算（合并能力的来源）

| 文件 | 本分支改动 |
|---|---|
| `Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift` | 新增（54 行，全部判定逻辑） |
| `Sources/BilibiliClientCore/App/RootView.swift` | 7 行（4 处锚点） |
| `Sources/BilibiliClientCore/Features/Dynamic/DynamicFeedView.swift` | 1 行 |
| `Sources/BilibiliClientCore/App/MenuBarPanelView.swift` | 1 行 |
| `scripts/build_app.sh` | 1 行代码 + 2 行注释 |
| `scripts/fork_check.sh` | 新增（43 行，锚点守卫） |

合计 6 文件 / +105 −10；**上游源码只动 9 行**。

## 合并纪律

1. 上游文件只允许出现上表那 9 行锚点改动；任何新逻辑进 `Sources/BilibiliClientCore/DeRecommend/`。
2. 不碰上游「每次发布 / 每次构建必改或必生成」的文件：`version.txt`、`docs/appcast.xml`、`AGENTS.md`、`Sources/BilibiliClientCore/Generated/BuildInfo.generated.swift`、`Package.resolved`。
   这一条与上游 `AGENTS.md` 的「每次提交自动升 version.txt」相左，是刻意的：我们升号会让每次同步都在这同一行上冲突。
3. 不删任何类型 / 端点 / View / 设置项——上游的单向删改不会与我们的改动互斥。
4. 同步用 `git fetch upstream main && git merge upstream/main`（或直接跑 `./scripts/fork_sync.sh`）；**不要 rebase 本分支的提交**。
5. 每次同步后跑 `./scripts/fork_check.sh`；有红按下面的兜底处理。
6. 本分支不打 `vX.Y.Z` tag、不发布正式 release、不改 `docs/appcast.xml`（避免与上游的发布流程撞车）。唯一例外是 CI 的滚动预发布 `ci-macos-arm64`：它只挂 CI 产物、不碰 `version.txt` 与 appcast。

## 冲突兜底

- **A. 守卫报「锚点缺失」但文件还在原处**：按锚点表补回 1–2 行——默认落地页 `= .dynamics`、`ForEach(DeRecommendation.browseItems)`、`case nil:` 后接 `DynamicFeedView()`、删掉 `Tab("推荐"/"分区"/"热门"/"直播")` 四行。
- **B. `git merge` 在移动后的文件上报冲突**（上游目录重构 + 大改同一文件；历史上 `v1.7.3→v1.8.2` 的 Core 抽取就是这种形态）：
  `git checkout --theirs <冲突文件>` 先接受上游版本，再在新路径上重放 4 处锚点（共 7 行），`./scripts/fork_check.sh` 全绿后提交。
- **C. 不想维护分支历史**：在干净的上游树上 `git apply --3way <patch>` 重放（实测干净），冲突只会出现在上表那 4 个上游文件里。

## CI（macOS arm64）

`.github/workflows/build-macos-arm64.yml` 在 GitHub 托管的 `macos-26`（Apple Silicon）上打包：

- 触发：推送到本分支；`paths-ignore` 跳过纯文档改动
- 两个 job 并行：macOS（`.app.zip`，ad-hoc 签名）与 iOS（未签名 `.ipa`）
- 产物：`BilibiliClient-<version>-macos-arm64.app.zip`、`BilibiliClient-<version>-ios-arm64-unsigned.ipa` → 上传为 workflow artifact，并挂到滚动预发布 `ci-macos-arm64`
- 两个 job 的诊断分别写 `ci-status` 的 `run-<N>-macos.md` / `run-<N>-ios.md`（并发推送会撞车，故分文件）
- 失败诊断：无论成败都写 `ci-status` 分支（含 SDK/工具链版本、错误行、日志头尾、产物 sha256），无需登录即可读
- 需要的 5 个环境覆盖（都在 workflow 里）：`SDKROOT=$(xcrun --show-sdk-path)`、`ACTOOL`、`SIGN_IDENTITY='-'`、`NO_OPEN=1`、`KEEP_ARCHIVE=1`；`fetch-depth: 0` 保 `CFBundleVersion`
- 经验教训见工作区 `docs/github-actions-macos-arm64-lessons.md`

## 本机环境说明

这台机器 `$HOME` 只读，所以 git 身份与 SSH 配置都写在仓库内：身份在 `.git/config`，SSH 走 `core.sshCommand`（配置见工作区 `.ssh/config`）。推送用 deploy key（只对单个仓库生效），见仓库 Settings → Deploy keys。
