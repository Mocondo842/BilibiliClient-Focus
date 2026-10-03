# CI 运行 #11（iOS arm64 未签名 IPA）— success

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `3e543c8b8bcd3b959f27be6980d4253d5b6c7bee` |
| 触发 | push by Mocondo842 |
| 结果 | **success** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| iOS SDK | /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37119791448 |

## 关键行（错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
```

## 构建日志全文（共       80 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
[0/1] Planning build
Building for production...
[0/3] Write sources
[1/3] Write swift-version-7974D3F7F03D5E95.txt
[3/4] Compiling BilibiliClientCore AppDelegate.swift
[3/6] Write sources
[5/7] Compiling BilibiliClientiOS BilibiliClientiOSApp.swift
[5/7] Write Objects.LinkFileList
clang: warning: using sysroot for 'MacOSX' but targeting 'iPhone' [-Wincompatible-sysroot]
[6/7] Linking BilibiliClientiOS
Build of product 'BilibiliClientiOS' complete! (60.27s)
Binary: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/arm64-apple-ios/release/BilibiliClientiOS
2026-10-03 11:30:59.517 AssetCatalogSimulatorAgent[25540:66629] The filter 'CIPortraitEffectSpillCorrection' is not implemented in the bundle at /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreImage/PortraitFilters.cifilter.
Wrote /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app/Info.plist
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app
No errors detected in compressed data of /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa.
-rw-r--r--  1 runner  staff   6.7M Oct  3 11:31 /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
Generated: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
-rw-r--r--  1 runner  staff  6994602 Oct  3 11:31 dist/ios/BilibiliClient-unsigned.ipa
Archive:  dist/ios/BilibiliClient-unsigned.ipa
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  10-03-2026 11:31   Payload/
        0  10-03-2026 11:31   Payload/BilibiliClient.app/
        0  10-03-2026 11:31   Payload/BilibiliClient.app/_CodeSignature/
     2498  10-03-2026 11:31   Payload/BilibiliClient.app/_CodeSignature/CodeResources
    14760  10-03-2026 11:31   Payload/BilibiliClient.app/Bilibiliclient76x76@2x~ipad.png
 18281664  10-03-2026 11:31   Payload/BilibiliClient.app/BilibiliClient
  2660264  10-03-2026 11:31   Payload/BilibiliClient.app/Assets.car
    10189  10-03-2026 11:31   Payload/BilibiliClient.app/Bilibiliclient60x60@2x.png
     2345  10-03-2026 11:31   Payload/BilibiliClient.app/Info.plist
--- 架构 ---
arm64
--- 构建平台 ---
/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.rvr1pMODxu/Payload/BilibiliClient.app/BilibiliClient:
Load command 11
      cmd LC_BUILD_VERSION
  cmdsize 32
 platform IOS
    minos 26.0
      sdk 26.5
   ntools 1
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.5 
CFBundleVersion = 171 
MinimumOSVersion = 26.0 
CFBundleIcons = Dict {     CFBundlePrimaryIcon = Dict {         CFBundleIconFiles = Array { 
CFBundleIcons~ipad = Dict {     CFBundlePrimaryIcon = Dict {         CFBundleIconFiles = Array { 
--- 签名状态（应为未签名）---
Executable=/private/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.rvr1pMODxu/Payload/BilibiliClient.app/BilibiliClient
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
  ok    动态流过滤
  ok    菜单栏面板过滤

[4/4] 自动更新
  ok    Sparkle 默认 feed 不指向上游

结果：全部锚点在位（补丁完整）

=== 预发布资产复核（iOS） ===
total 13672
-rw-r--r--  1 runner  staff  6994602 Oct  3 11:31 BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
-rw-r--r--  1 runner  staff      115 Oct  3 11:31 BilibiliClient-1.9.5-ios-arm64-unsigned.ipa.sha256
iOS 预发布资产校验：OK（sha256=0e92d79e2f870c1775400bfbf9d2a6798dbd8ac131f5c0b346ee490cc3e39c88）
=== 复核结束 ===
```

## 产物

```
-rw-r--r--  1 runner  staff  6994602 Oct  3 11:31 dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
-rw-r--r--  1 runner  staff      115 Oct  3 11:31 dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa.sha256
0e92d79e2f870c1775400bfbf9d2a6798dbd8ac131f5c0b346ee490cc3e39c88  dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
```
