# CI 运行 #13（iOS arm64 未签名 IPA）— failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `6b680d18b6d33f29ebcb17c4062b039126830745` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| iOS SDK | /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37122865038 |

## 关键行（错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
```

## 构建日志全文（共       72 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
[0/1] Planning build
Building for production...
[0/5] Write sources
[2/5] Write swift-version-7974D3F7F03D5E95.txt
[4/6] Compiling BilibiliClientCore AppDelegate.swift
[5/7] Compiling BilibiliClientiOS BilibiliClientiOSApp.swift
[5/7] Write Objects.LinkFileList
clang: warning: using sysroot for 'MacOSX' but targeting 'iPhone' [-Wincompatible-sysroot]
[6/7] Linking BilibiliClientiOS
Build of product 'BilibiliClientiOS' complete! (45.68s)
Binary: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/arm64-apple-ios/release/BilibiliClientiOS
2026-10-03 12:28:12.133 AssetCatalogSimulatorAgent[57391:135845] The filter 'CIPortraitEffectSpillCorrection' is not implemented in the bundle at /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreImage/PortraitFilters.cifilter.
Wrote /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app/Info.plist
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app
No errors detected in compressed data of /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa.
-rw-r--r--  1 runner  staff   6.7M Oct  3 12:28 /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
Generated: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
-rw-r--r--  1 runner  staff  7014645 Oct  3 12:28 dist/ios/BilibiliClient-unsigned.ipa
Archive:  dist/ios/BilibiliClient-unsigned.ipa
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  10-03-2026 12:28   Payload/
        0  10-03-2026 12:28   Payload/BilibiliClient.app/
        0  10-03-2026 12:28   Payload/BilibiliClient.app/_CodeSignature/
     2498  10-03-2026 12:28   Payload/BilibiliClient.app/_CodeSignature/CodeResources
    14760  10-03-2026 12:28   Payload/BilibiliClient.app/Bilibiliclient76x76@2x~ipad.png
 18407808  10-03-2026 12:28   Payload/BilibiliClient.app/BilibiliClient
  2660264  10-03-2026 12:28   Payload/BilibiliClient.app/Assets.car
    10189  10-03-2026 12:28   Payload/BilibiliClient.app/Bilibiliclient60x60@2x.png
     2345  10-03-2026 12:28   Payload/BilibiliClient.app/Info.plist
--- 架构 ---
arm64
--- 构建平台 ---
/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.bDpXV41Sp3/Payload/BilibiliClient.app/BilibiliClient:
Load command 11
      cmd LC_BUILD_VERSION
  cmdsize 32
 platform IOS
    minos 26.0
      sdk 26.5
   ntools 1
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.5 
CFBundleVersion = 175 
MinimumOSVersion = 26.0 
CFBundleIcons = Dict {     CFBundlePrimaryIcon = Dict {         CFBundleIconFiles = Array { 
CFBundleIcons~ipad = Dict {     CFBundlePrimaryIcon = Dict {         CFBundleIconFiles = Array { 
--- 签名状态（应为未签名）---
Executable=/private/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.bDpXV41Sp3/Payload/BilibiliClient.app/BilibiliClient
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
