# CI 运行 #13（macOS arm64）— failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `6b680d18b6d33f29ebcb17c4062b039126830745` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37122865038 |

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
Archived: dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip
Mach-O 架构: arm64
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.5
CFBundleVersion = 175
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
  FAIL  动态流过滤（锚点缺失）
  ok    菜单栏面板过滤

[4/4] 自动更新
  ok    Sparkle 默认 feed 不指向上游

结果：有锚点缺失——同步上游后需要重放补丁，做法见 FORK.md
```

## 构建日志全文（共       35 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
Signed with: -
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
Archived: dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip
Mach-O 架构: arm64
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.5
CFBundleVersion = 175
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
  FAIL  动态流过滤（锚点缺失）
  ok    菜单栏面板过滤

[4/4] 自动更新
  ok    Sparkle 默认 feed 不指向上游

结果：有锚点缺失——同步上游后需要重放补丁，做法见 FORK.md
```

## 产物

```
(无)
```
