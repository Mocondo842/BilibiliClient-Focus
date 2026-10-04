# CI 运行 #18（macOS arm64）— success

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `bd4552c602f7d3de4e96409ceac69106370caf99` |
| 触发 | push by Mocondo842 |
| 结果 | **success** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37182263507 |

## 关键行（SDK / 错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

## 构建日志开头（前 40 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
Signed with: -
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
Archived: dist/archive/1.9.7/BilibiliClient-v1.9.7.app.zip
Mach-O 架构: arm64
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.7
CFBundleVersion = 180
LSMinimumSystemVersion = 26.0
SUFeedURL = https://example.invalid/bilibiliclient-fork/appcast.xml
--- 签名 ---
Executable=/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS/BilibiliClient
Identifier=com.codex.bilibili-client
Format=app bundle with Mach-O thin (arm64)
--- 去推荐化锚点守卫 ---
[1/4] 补丁文件
  ok    DeRecommendation.swift 存在
  ok    browseItems 只留动态
  ok    官方注入类型黑名单仍在
  ok    MAJOR_TYPE_LIVE_RCMD 兜底仍在
  ok    空条目兜底判定仍在
[2/4] 导航
  ok    默认落地页 = 动态
  ok    侧边栏/标签栏用补丁清单
  ok    空选中回落到动态
  ok    iOS 标签栏不含推荐/分区/热门/直播
[3/4] 过滤
  ok    去推荐化：动态流过滤仍在
  ok    仅视频筛选仍在
  ok    本地播放进度仍在
  ok    就绪后恢复进度（切清晰度不丢位置）仍在
  ok    播完清进度仍在
  ok    登录兜底存储仍在
  ok    三条播放路径共用收尾（进度/解码信息）仍在
  ok    自动播放开关仍在
  ok    动态评论区仍在
  ok    优先清晰度仍在
  ok    优先编码仍在
  ok    评论字号缩放仍在
```

## 构建日志全文（共       65 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
Signed with: -
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
Archived: dist/archive/1.9.7/BilibiliClient-v1.9.7.app.zip
Mach-O 架构: arm64
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.7
CFBundleVersion = 180
LSMinimumSystemVersion = 26.0
SUFeedURL = https://example.invalid/bilibiliclient-fork/appcast.xml
--- 签名 ---
Executable=/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS/BilibiliClient
Identifier=com.codex.bilibili-client
Format=app bundle with Mach-O thin (arm64)
--- 去推荐化锚点守卫 ---
[1/4] 补丁文件
  ok    DeRecommendation.swift 存在
  ok    browseItems 只留动态
  ok    官方注入类型黑名单仍在
  ok    MAJOR_TYPE_LIVE_RCMD 兜底仍在
  ok    空条目兜底判定仍在
[2/4] 导航
  ok    默认落地页 = 动态
  ok    侧边栏/标签栏用补丁清单
  ok    空选中回落到动态
  ok    iOS 标签栏不含推荐/分区/热门/直播
[3/4] 过滤
  ok    去推荐化：动态流过滤仍在
  ok    仅视频筛选仍在
  ok    本地播放进度仍在
  ok    就绪后恢复进度（切清晰度不丢位置）仍在
  ok    播完清进度仍在
  ok    登录兜底存储仍在
  ok    三条播放路径共用收尾（进度/解码信息）仍在
  ok    自动播放开关仍在
  ok    动态评论区仍在
  ok    优先清晰度仍在
  ok    优先编码仍在
  ok    评论字号缩放仍在
  ok    菜单栏面板过滤
[3b/4] 播放器瞬时状态（切清晰度不许重建画面/播放器）
  ok    换清晰度沿用播放状态（是否在播/音量）仍在
  ok    换清晰度复用同一 AVPlayer 实例仍在
  ok    画面不随 loading 增删（原生全屏才不会被踢）仍在
  ok    三条播放路径都用 replaceCurrentItem 换流（画面不重建）
  ok    三条播放路径都走共用收尾（起播策略/进度/解码信息）
  ok    播放器实例不被整体替换（视频播放器的赋值点）

[4/4] 自动更新
  ok    Sparkle 默认 feed 不指向上游

结果：全部锚点在位（补丁完整）
--- 归档 ---
-rw-r--r--  1 runner  staff  5470842 Oct  4 06:16 dist/archive/1.9.7/BilibiliClient-v1.9.7.app.zip

=== 预发布资产复核（在 runner 上把刚上传的东西拉回来） ===
total 21392
-rw-r--r--  1 runner  staff  5469287 Oct  4 06:16 BilibiliClient-1.9.5-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  4 06:16 BilibiliClient-1.9.5-macos-arm64.app.zip.sha256
-rw-r--r--  1 runner  staff  5470842 Oct  4 06:16 BilibiliClient-1.9.7-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  4 06:16 BilibiliClient-1.9.7-macos-arm64.app.zip.sha256
预发布资产校验：OK（sha256=5b57a50c447e3ae299b4247a1251c27df0cc525af7d2d27a66ad07d25b3deea1
b3a0ad23eca3500e2830a6c4cdad03cc7a02df91ee7a30390899cc071f7cc8b5）
=== 复核结束 ===
```

## 产物

```
-rw-r--r--  1 runner  staff  5470842 Oct  4 06:16 dist/BilibiliClient-1.9.7-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  4 06:16 dist/BilibiliClient-1.9.7-macos-arm64.app.zip.sha256
b3a0ad23eca3500e2830a6c4cdad03cc7a02df91ee7a30390899cc071f7cc8b5  dist/BilibiliClient-1.9.7-macos-arm64.app.zip
```
