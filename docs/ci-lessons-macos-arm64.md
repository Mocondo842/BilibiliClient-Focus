# 用 GitHub Actions 打包 macOS arm64 / iOS 桌面客户端：可行性判据与 6 个真实的坑

> 本文档有两份同内容副本：仓库 `docs/ci-lessons-macos-arm64.md`（本文件，随代码走）与工作区 `docs/github-actions-macos-arm64-lessons.md`（主副本，记忆条目的 `canonical` 指向它）。更新时两份一起改。

对象：`Mora-han/BilibiliClient` 的 fork（`Mocondo842/BilibiliClient-Focus`，SwiftUI + SwiftPM，要求 macOS 26 / iOS 26，Xcode 26）
时间：2026-10-03，本机为 Linux（无 Swift、无 Xcode），全程靠 CI 完成编译与打包
结论：**可行**。macOS arm64 runner 免费可用；11 次运行后两个 job 全绿：macOS 版 `.app.zip`（5.2 MB，ad-hoc 签名）与 iOS 版未签名 `.ipa`（7.0 MB），都挂在滚动预发布里。11 次失败里没有一次证明「macOS 打包不可行」——全是环境假设、诊断可见性与脚本文法。

本文写给"打算给 macOS 客户端接 CI"或"要在 fork 里长期维护一份补丁"的相似项目，可以整段抄进 issue/PR。

---

## 一、可行性判据（先查这 4 条，再动手）

1. **runner 是否有目标架构与工具链**：`macos-26` 已于 2026-02-26 由 public preview 转 GA，**原生 Apple Silicon（arm64）**；镜像内默认 Xcode 26.6（17F113），另有 26.5 / 26.4.1 / 26.3 / 26.2 / 26.1.1 / 26.0.1 可选。
   判据来源：`actions/runner-images` 的 `images/macos/macos-26-arm64-Readme.md`（含 Xcode 与 SDK 清单）+ GitHub changelog《macOS 26 is now generally available for GitHub-hosted runners》。
   本项目的硬门槛是 `Package.swift` 的 `swift-tools-version: 6.2` 与 `.macOS(.v26)` —— runner 上实测 `swift --version` = **6.3.3**，满足。
2. **计费**：公开仓库使用 GitHub 托管 runner 免费（私有仓库 macOS 计 10× 分钟）。
3. **fork 的 Actions 是否启用**：fork 默认可能不跑 workflow。本 fork 已启用（推上去立刻排队）；若没启用，push 不会产生任何 run，需要仓库 Settings → Actions 里点一次允许。
4. **有没有必须在 GUI 会话里做的事**：本项目构建脚本尾段会 `open` 打开 App，用 `NO_OPEN=1` 关掉即可；签名、图标编译都能在无证书的 runner 上跑（见坑 3）。

---

## 二、没有 PAT 时，主代理怎么"看见"CI（自监督的关键设计）

这是本次最值得抄的一段经验。**观测能力决定了能不能自监督**：

| 通道 | 未认证可用性 | 能拿到什么 |
|---|---|---|
| REST `GET /repos/{o}/{r}/actions/runs` | ✅ 200 | run 列表、状态、结论、run_number |
| REST `…/actions/runs/{id}/jobs` | ✅ 200 | **每个 step 的结论**（定位到哪一步红） |
| REST `…/jobs/{id}/logs` | ❌ 403（需 admin） | 拿不到 |
| 网页 HTML | ✅ 200 | 只有壳，状态在 JS 里，不好解析 |
| **workflow 自己推到分支的诊断文件** | ✅ 走 git | **失败原因**（自己决定写什么） |
| `codeload.github.com/…/tar.gz/refs/heads/<branch>` | ✅ | 读任意分支的文件，比 `git fetch` 稳（本机 git 走 github.com 常超时） |
| `github.com`（release 资产下载页） | ❌ 本机连不上 | 下载 release 资产要用别的办法（见下） |

还有一个"看起来像失败、其实不是"的信号值得记住：**运行创建了、结论是 failure，但 `jobs` 数组是空的** —— 这不是作业失败，而是 **workflow 文件本身没通过校验**（见坑 5）。区分这两种情况，能省掉一整轮瞎猜。

于是本项目做成两层：

1. **步骤级定位**：主代理轮询 runs/jobs，看到"第 5 步 构建 失败"。
2. **原因级定位**：workflow 里一个 `if: always()` 的步骤，把 SDK、错误行、日志头尾、产物哈希写进 `ci-status` 分支；主代理用 codeload 取回来看。

配额注意：未认证 API 是 **60 次/小时**，`runs`+`jobs` 每次轮询 2 次调用，密集轮询十分钟就耗尽；届时退化为 codeload 通道（不占配额）。

**本机连不上 github.com 的连带影响**：release 资产下载（`github.com/.../releases/download/...`）在本机拿不到，所以"资产完整性"的验证被搬进 CI 自身：

```yaml
- name: 复核预发布资产（下载回来验哈希）
  env: { GH_TOKEN: '${{ secrets.GITHUB_TOKEN }}' }
  run: |
    D="$(mktemp -d)"
    gh release download ci-latest -p '*.zip' -p '*.sha256' -D "$D"
    [ "$(cut -d' ' -f1 "$D"/*.sha256)" = "$(shasum -a 256 "$D"/*.zip | cut -d' ' -f1)" ]
```

---

## 三、六个真实的坑（每个都花掉至少一轮 CI）

### 坑 1：SDKROOT 指向 CommandLineTools，SwiftUI 的宏插件就找不到

- **现象**：构建依赖 `swiftui-math` 时报
  `external macro implementation type 'PreviewsMacros.SwiftUIView' could not be found for macro 'Preview(_:body:)'`。
- **机制**：构建脚本里有一段"聪明"的 SDK 选择——
  `if [ -d "/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk" ]; then export SDKROOT=<CLT SDK>; else export SDKROOT="$(xcrun --show-sdk-path)"; fi`。
  runner 上那个 CLT SDK 路径**恰好存在**，而 Xcode 是 26.6 → SDK 与 toolchain 不一致，宏插件查找落空。
- **处置**（不改上游脚本）：CI 里显式 `export SDKROOT="$(xcrun --show-sdk-path)"`——脚本用 `[ -z "${SDKROOT:-}" ]` 判断，外部值会被尊重。
- **教训**：构建脚本里"能猜就猜"的 SDK/工具链探测是 CI 的常见雷；**CI 必须把 SDK、toolchain、目标架构全部显式钉住**，让本地与 CI 只差环境不差逻辑。

### 坑 2：Linux 侧再密的静态核对，也抓不到类型错误

补丁里有一行 `blockedMajorTypes.contains(major.type)`，而 `major.type` 是 `String?` —— Swift 报
`value of optional type 'String?' must be unwrapped to a value of type 'String'`。
本机没有 Swift，只能做文本级锚点检查与三方合并实验，这类错误**必然漏网**。

- **教训**：任何标着"未编译验证"的方案，第一步就该是**给它接一个真编译器**（哪怕只是 `swift build` 的 CI 环）。这次上 CI 的直接收益就是它。

### 坑 3：`VAR="$(cmd | grep …)"` 在 `set -e` + `pipefail` 下是沉默的杀手

- **现象**：构建日志停在 `Embedded: Sparkle.framework` 之后再无任何输出，脚本直接退出（退出码非 0，但没有一行报错）。连续三轮（run #3/#4/#5）都死在这里。
- **机制**：
  ```bash
  SIGN_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
    | grep -o '"\(Apple Development\|Developer ID Application\|Mac Developer\)[^"]*"' | head -1 | tr -d '"')"
  ```
  runner 上没有任何签名证书 → `grep` 无匹配返回 1 → 管道整体返回 1 → **赋值语句本身"失败"** → `set -e` 让脚本结束。作者本机有证书，所以这条路径永远不会被本地构建暴露。
- **处置**：CI 显式给 `SIGN_IDENTITY='-'`（ad-hoc 身份），让脚本走"已知身份"分支，绕开那段管道；签名结果正常（`Signed with: -`）。
- **教训**：凡是 `VAR="$(… | grep …)"` 都要么给 `|| true`，要么显式提供值。**"没有输出就退出"是排查成本最高的一类失败**。

### 坑 4：诊断必须写进"读得到的那张纸"

这一条是被坑 3 逼出来的，值得单独记：

- 脚本里 `"$ACTOOL" --compile … >/dev/null` 把 **actool 的诊断吞掉了**（actool 把错误写 **stdout**，不是 stderr）。于是失败现场只剩"下一行 `test -f Assets.car` 不成立"。
- 我第一版诊断把信息 `echo` 到了**步骤日志**——而未认证的下载日志接口是 **403（需 admin）**，等于白跑一轮。
- 最终做法：**失败诊断一律 `>> build.log`**，并让 CI 卡在报告里带上：SDK/工具链版本、错误行（去重）、日志头 40 行 + 尾 150 行；日志短于 300 行就直接收全文。真相（actool 其实完全正常）就是这样拿到的。

### 坑 5：只有注释的 `env:` 块会让整个 workflow 文件非法

为了临时关掉 xtrace，我把

```yaml
        env:
          TRACE: '1'   # 排查期开
```

改成了

```yaml
        env:
          # TRACE: '1'  # 排查时打开
        run: |
```

结果是 `env:` 成了空值（null）。GitHub 的校验器不接受这个形状 → **整个 workflow 文件非法** → 触发后创建的运行**没有任何 job**、几秒内变为 failure，也不会有诊断可写（我因此白等了一轮才反应过来）。

- **教训**：YAML 里不要留"只有注释的键"。要么删掉整个 `env:`，要么留一个真值；把开关放进注释时，连键一起注释掉。
- **判断信号**：运行 failure 且 `jobs` 为空 = 文件非法，不是作业失败。
- **本机自保**：推送前用 docker 里的 js-yaml 解析一遍（宿主没有 YAML 解析器也能做）：
  ```bash
  docker run --rm -v "$PWD":/w -w /w node:20 sh -c "npx -y js-yaml .github/workflows/<file>.yml >/dev/null && echo OK"
  ```

### 坑 6：`$VAR` 紧贴非 ASCII 字符，会被当成变量名的一部分

资产复核那一步里我写了：

```bash
echo "预发布资产校验：OK（sha256=$ACTUAL）"
```

中文全角 `）` 紧跟 `$ACTUAL`。bash 把紧跟的字节并进了变量名 → `set -u` 下直接报
`ACTUAL�: unbound variable`，于是**构建全绿、却死在最后一行日志上**（run #8）。

- **教训**：shell 里一律写 `${VAR}`。这个坑在中文注释/日志满天飞的脚本里尤其容易踩——我在 run #5 也被它咬过一次（`$RC；` 打印成乱码），只是那次没有 `set -u` 没致命。
- **本机自保**：正则扫一遍 `\$[A-Za-z_][A-Za-z0-9_]*[^\x00-\x7F]`，命中就改：
  ```bash
  grep -nP '\$[A-Za-z_][A-Za-z0-9_]*[^\x00-\x7F]' .github/workflows/*.yml   # 有命中就加花括号
  ```

---

## 四、让 CI 与工程约定对齐的 5 个覆盖（全部不改上游代码）

| 覆盖 | 为什么必须 |
|---|---|
| `fetch-depth: 0` | 构建号 `CFBundleVersion = git rev-list --count HEAD`；浅克隆会退化成 `1` |
| `ACTOOL` | 脚本默认写死 `/Applications/Xcode-beta.app/...`，runner 上不存在；实际在 `/Applications/Xcode.app/Contents/Developer/usr/bin/actool`（`/usr/bin/actool` 是 shim） |
| `SDKROOT` | 见坑 1 |
| `SIGN_IDENTITY='-'` | 见坑 3 |
| `NO_OPEN=1` `KEEP_ARCHIVE=1` | 无 GUI 会话；并产出可上传的 `dist/archive/<version>/*.zip` |

配套还用了：`actions/cache` 缓存 `.build` 与 `~/Library/Caches/org.swift.swiftpm`（键用 `hashFiles('Package.resolved')`）、`concurrency` 防重入、`permissions: contents: write`（推诊断分支与建预发布都要）、`timeout-minutes: 45`。

---

## 四之二、同一 workflow 里加 iOS 未签名 IPA（差异清单）

同一个 `macos-26` runner 就能出 iOS 产物（`scripts/build_ios_app.sh release` → `dist/ios/BilibiliClient-unsigned.ipa`），但与 macOS job 有 4 处**必须区别对待**：

| 项 | macOS job | iOS job |
|---|---|---|
| `SDKROOT` | **必须显式设为 Xcode SDK**（坑 1） | **绝不设置**：脚本明确要求——SwiftPM 连 manifest 都会用 SDKROOT 编译，会被 iOS SDK 带偏 |
| `fetch-depth: 0` | 需要（`CFBundleVersion` = 提交数） | 同样需要（同一套 BUILD 逻辑） |
| `ACTOOL` | 需要覆盖（默认写死 Xcode-beta） | 同样需要（图标是共用资源 `assets/Bilibiliclient.icon`） |
| 签名 | ad-hoc（`SIGN_IDENTITY='-'`） | 真机 IPA **保持未签名**，交给 AltStore/Sideloadly 自签；模拟器包才 ad-hoc |
| 静态自检重点 | `lipo -archs` 含 arm64、plist 键、`codesign -dv` | IPA 结构（`unzip -l` 里有 `Payload/*.app`）、`vtool -show-build` 的 `platform IOS`、`MinimumOSVersion`、`CFBundleIcons` / `CFBundleIcons~ipad` |
| 缓存 key | `spm-…` | `spm-ios-…`（分开，避免两个 job 的 `.build` 缓存互相覆盖） |

两个 job 的诊断**必须分文件**（`run-<N>-macos.md` / `run-<N>-ios.md`），否则并发推送互相覆盖；`gh release create` 也要容忍并发。

---

## 五、fork 化客户端的额外陷阱：自动更新会把补丁抹掉

本项目用 Sparkle，`CFBundleVersion` 取 git 提交数，`SUFeedURL` 默认指向上游的 appcast。后果：**上游 release 的提交数一旦反超你 fork 的最后提交，App 会把官方版当"更新"下载并就地替换**——补丁被静默抹掉，且难以察觉。
处置（本 fork 的做法）：把 `SUFeedURL` 的默认值改成本分支自己的 appcast（1 行），并在 CI 的锚点守卫里加一条检查；CI 产出的构建因此天生不会回退到官方版。

同类项目自查清单：`CFBundleVersion` 是否用提交数 / 是否有人在订阅上游的 appcast / 产物里 `SUFeedURL` 指向哪里。

---

## 六、建议回报上游的 3 处最小修复（合计 3 行）

都是"让构建在无 GUI、无证书、非 Xcode-beta 环境下可用"的改动，不涉及业务逻辑：

1. **SDK 选择不要只认 CLT**（坑 1）：现在只要 `/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk` 存在就优先用它；建议改为"仅当它与当前 toolchain 匹配时才用"，或直接去掉这段猜测、统一 `xcrun --show-sdk-path`。
2. **签名身份探测加兜底**（坑 3）：
   `SIGN_IDENTITY="$(… | grep … | head -1 | tr -d '"' || true)"`，或先判断有无证书再赋默认值 `-`。
3. **actool 的诊断别吞**（坑 4）：`"$ACTOOL" … >/dev/null` 改成 `2>&1`（或在 `test -f Assets.car` 失败时回显一次），否则图标编译失败时没有任何线索。

---

## 七、时间线（18 次运行）

| run | 结果 | 直接原因 | 修复 |
|---|---|---|---|
| 1 | fail | `PreviewsMacros` 插件找不到（CLT SDK 优先） | 显式 `SDKROOT=$(xcrun --show-sdk-path)` |
| 2 | fail | 我自己补丁里的 `String?` → `Set.contains` | 解包后比较 |
| 3 | fail | 静默退出（签名身份管道），误以为是 actool | 加 actool 诊断 |
| 4 | fail | 同上（诊断打到了读不到的步骤日志） | 诊断改写进 `build.log` |
| 5 | fail | 同上（诊断终于可见，证明 actool 正常，锁定签名身份管道） | 显式 `SIGN_IDENTITY='-'` |
| 6 | **success** | — | 产物 `BilibiliClient-1.9.5-macos-arm64.app.zip`（5.2 MB），`Signed with: -` |
| 7 | fail | 只有注释的 `env:` 块 → workflow 文件非法，**零 job** | 删掉空 `env:`，并加 js-yaml 预校验 |
| 8 | fail | 资产复核里 `$ACTUAL` 紧贴全角 `）` → `set -u` 报 unbound（构建本身已绿） | 改用 `${VAR}` + 机械扫描 |
| 9 | **success** | — | 静态自检全过；**资产回下载校验 OK**（sha256 `84259ebd…96ab`，5,449,329 bytes） |
| 10 | **success** | — | 加上 iOS job：macOS 5,449,340 B + iOS `.ipa` 6,994,581 B，两份资产各自回下载校验 OK |
| 11 | **success** | — | 把静态自检输出也 tee 进 `build.log`：报告里现在能看到 Mach-O `arm64`、`CFBundleVersion=171`、`LSMinimumSystemVersion=26.0`、`SUFeedURL` 指向本分支、iOS 的 `platform IOS` 与 `CFBundleIcons`、以及「未签名」状态 |
| 12 | fail | `PlayerController.swift:266:17: error: expression is 'async' but is not marked with 'await'` | async 上下文选中了 `AVPlayer` 的 async `seek` 重载 → `_ = await player?.seek(...)` |
| 13 | fail | 构建绿、守卫红：`need 'guard selectedUP != nil else { return items.followOnly }'` 不再匹配 | 守卫改成锚定稳定符号（`items.followOnly`/`videoOnly`），并加功能锚点（**守卫红是设计**） |
| 14 | **success** | — | 五项功能落地；守卫 22 项全绿；`CFBundleVersion=175` |
| 15 | **success** | — | 三项修复（切清晰度丢位置 / 播完复习不清 / 登录不持久 + 评论字号 + 动态评论区）；`CFBundleVersion=177` |
| 16 | **success** | — | 低清晰度路径统一（`finishPlayerSetup`）+ 自动播放开关 + 动态评论区字号；`CFBundleVersion=178` |
| 17 | fail | `VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope` | 该文件首次**写出** AV 类型名（`mountedPlayer: AVPlayer?`），只 import 了 SwiftUI → 补 `import AVFoundation` |
| 18 | **success** | — | 复用同一 `AVPlayer` 实例（`replaceCurrentItem`）+ 画面常驻条件分支之外 + 切清晰度沿用播放状态；守卫 28 项全绿；`CFBundleVersion=180`（v1.9.7） |

第 6 / 9 次的实测环境：`arm64 / macOS 26.6.2 / Xcode 26.6 (17F113) / Swift 6.3.3`；静态自检通过（Mach-O 含 `arm64`、`Info.plist` 关键键齐全、去推荐化锚点守卫全绿）；run #9 额外把预发布资产下载回来比对了 sha256。

---

## 七之二、推送前的三道零成本校验（都被真实事故教过一次）

```bash
# 1) YAML 能否解析（坑 5：空 env 块让整个文件非法）
docker run --rm -v "$PWD":/w -w /w node:20 sh -c "npx -y js-yaml .github/workflows/x.yml >/dev/null && echo OK"
# 2) $VAR 是否紧贴非 ASCII（坑 6）
grep -nP '\$[A-Za-z_][A-Za-z0-9_]*[^\x00-\x7F]' .github/workflows/*.yml
# 3) 抽出每个 run: 块、按公共缩进去缩进、逐个 bash -n
```

三条都是秒级，能挡掉「推上去才发现整份 workflow 非法 / 脚本语法错」这类代价最高的错误——CI 一轮至少 5 分钟，macOS runner 排队时更久。

---

## 八、可直接复用的 workflow 骨架

```yaml
name: build-macos-arm64
on:
  workflow_dispatch:
  push:
    branches: [<你的分支>]
    paths-ignore: ['**/*.md']

concurrency:
  group: build-macos-arm64-${{ github.ref }}
  cancel-in-progress: true
permissions:
  contents: write          # 推诊断分支 / 建预发布

jobs:
  macos-arm64:
    runs-on: macos-26      # Apple Silicon（arm64），默认 Xcode 26.6
    timeout-minutes: 45
    env:
      NO_OPEN: '1'
      KEEP_ARCHIVE: '1'
      ACTOOL: /Applications/Xcode.app/Contents/Developer/usr/bin/actool
      SIGN_IDENTITY: '-'
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }        # 构建号用提交数时必须
      - name: 环境自检
        run: |
          uname -m; sw_vers; xcodebuild -version; swift --version
          echo "SDK: $(xcrun --show-sdk-path)"; echo "actool: $(xcrun --find actool)"
      - uses: actions/cache@v4
        with:
          path: |
            .build
            ~/Library/Caches/org.swift.swiftpm
          key: spm-${{ runner.os }}-${{ hashFiles('Package.resolved') }}
      - name: 构建
        run: |
          set -o pipefail
          export SDKROOT="$(xcrun --show-sdk-path)"      # 别让脚本用 CLT SDK
          ./scripts/build_app.sh release 2>&1 | tee build.log
      - name: 静态自检
        run: |
          set -euo pipefail
          APP=dist/BilibiliClient.app
          lipo -archs "$APP/Contents/MacOS/BilibiliClient" | grep -q arm64
          for k in CFBundleShortVersionString CFBundleVersion LSMinimumSystemVersion SUFeedURL; do
            printf '%s = %s\n' "$k" "$(/usr/libexec/PlistBuddy -c "Print :$k" "$APP/Contents/Info.plist")"
          done
      - uses: actions/upload-artifact@v4
        with: { name: app-arm64, path: 'dist/*.zip' }
      - name: 诊断落盘（失败也要能看到原因）
        if: always()
        run: |
          # 把日志头尾/错误行写进一个 git 分支，主代理用 codeload 读取，
          # 因为未认证下载步骤日志是 403。
          ...
```

---

## 九、给相似项目的一句话总结

**可行性没有疑问（macos-26 就是 arm64 + Xcode 26），真正花时间的是"环境假设"与"观测能力"**：
把 SDK、工具链、签名身份、GUI 交互、构建号来源全部显式化；让 CI 把失败原因写到你**确实读得到**的地方（分支文件而不是步骤日志）；推送前在本机做两道零成本校验（YAML 解析、`$VAR` 邻接扫描）；然后假设构建脚本里的每一处"智能猜测"、以及你自己写的每一行 shell，都会在 CI 上翻车。

九次运行里，真正属于"macOS 打包不可行"的证据是 **0 次**；6 次失败全部是环境假设、可见性、YAML/shell 细节。

---

## 十、这份文档如何「进入记忆」并持续更新

本文档同时以**主题记忆条目**的形式存在于 MemSearch 的索引目录里：

- 记忆条目：`/home/mocondo/ObsidianVault/memory/topic-github-actions-macos-arm64.md`
  （该目录是 memsearch 的索引根：`$MEMSEARCH_DIR=/home/mocondo/ObsidianVault`，索引状态见同目录 `.index-state.json` 的 `total_files` / `last_completed_at`）
- 条目里保留了「什么时候该调用这条记忆」一节——它决定召回是否打得准，更新时**不要删**。
- 更新流程：改本文件（工作区、随代码受版本控制）→ 用 `obsidian_write` 覆盖记忆条目并更新 frontmatter 的 `last_updated` / `status` → 索引由插件/watcher 的下一次运行完成。
- 手工强制索引：**需要先停 DSH**（Milvus Lite 是单进程，数据库被插件占用时会报 `Could not open the local Milvus database`），再跑
  `~/.local/bin/memsearch index /home/mocondo/ObsidianVault/memory`；用 `memsearch search "<关键词>"` 验证召回。

## 十一、补丁漏在三处：多路径、多渲染器、共用函数（run #12~#18）

run #14 之后连续四轮真机验收，暴露的都不是「API 不配合」，而是**同一个功能有多份实现**：

1. **多路径**：`play()` 里有三条起播路径——`qn <= 80` 走 MP4 直链、否则走 DASH 本地代理、两者都失败再走**在线流式兜底**（`tryProgressiveStreaming`）。第一轮补丁只加在 DASH 上：往 1080P 及以下切会从头播且解码信息不更新；到第三轮才发现流式兜底那条连自动播放设置都绕过了（它无条件 `play()`）。
   - 判断法：**「本该更新的状态没更新」+「本该恢复的行为没恢复」同时出现 = 那条路径整段没走**；症状的边界值（`qn <= 80`）往往就是那个 `if`。
2. **多渲染器**：评论区正文有两个渲染器（视频详情 `CommentCardView`、动态/图文详情 `DynamicCommentRowView`），改一个不等于改了功能 → 规则收敛到共享类型（`CommentFonts`）并写进守卫。
3. **共用函数**：把三条路径的收尾抽成 `finishPlayerSetup(summary:)` 之后，又把「按设置自动播放」写进了它——换清晰度也走这个函数，于是被误伤：关掉自动播放后一切清晰度就暂停。**共用收尾只做与场景无关的事（写状态/挂观察者/恢复进度/清理）；有场景差异的决策由调用方传入。**

### 1. 视图身份即生命周期（一次报障三个「bug」）

「切清晰度会退出全屏 / 音量像被重置 / 切完变成暂停」是同一个动作：换清晰度时 `player = nil` 再新建 `AVPlayer`，而画面视图是 `.id(player)`、外层还有 `switch player.state` 决定挂不挂它。

- SwiftUI 里 `.id` 变化、**条件分支切换**、把视图移出层级——三者任一发生，`NSViewRepresentable` 背后的 NSView 就被销毁重建。**AVKit 原生全屏挂在那个 view 上**，音量/静音/倍速挂在**播放器实例**上，所以重建 = 全屏被踢出 + 音量回默认。
- 两条对策：①**换内容不换容器**（`replaceCurrentItem(with:)`，别整体替换实例）；②**画面常驻**、放在条件分支之外——`.id` 相同**不足以**跨分支复用，别赌语义，直接别换分支。
- 多症状先**聚类**：问「这几个状态分别挂在谁身上、谁把它们一起干掉了」，三个独立 bug 常常只有一个动作（重建）。

### 2. 守卫要写「计数断言」和「禁止态断言」

- **存在性断言抓不到「漏一条路径」**：`grep -q finishPlayerSetup` 一直绿，而第三条路径根本没调用它。改成计数断言 `grep -c 'replaceCurrentItem(with:' >= 3` 立刻变红，把第三、第四条路径顶出来。
- **禁止态断言防回归**：`^[[:space:]]*player = AVPlayer\(`。要**锚定行首/赋值形态**——第一版写成 `player = AVPlayer\(` 就命中了直播播放器的 `let player = AVPlayer(playerItem:)`（合法写法），**误报比漏报更费时间**。
- 把路径条数写成断言还顺手证伪了「这条路径没问题」：计数从 2 提到 3 的那一刻，多出来的那条就是漏网的那条。

### 3. 本地没有工具链时，写出一个类型名 = 新增一个编译依赖

开发机没有 Swift/Xcode，**CI 是唯一的编译器**。给视图文件加 `private var mountedPlayer: AVPlayer?`（原来只写 `player.player != nil` 判空）→ `error: cannot find type 'AVPlayer' in scope`（run #17）。**不命名类型的写法不引入编译依赖**，所以「我只是把判空挪了个地方」也会红。推前自检加一条：**这次新写了哪些类型名？它们在每个受影响文件的 import 里吗？**
