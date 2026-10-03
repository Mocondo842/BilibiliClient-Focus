# CI 运行 #16（iOS arm64 未签名 IPA）— success

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `55ee7619e7f73bea8610a1919f6765250e932717` |
| 触发 | push by Mocondo842 |
| 结果 | **success** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| iOS SDK | /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37128865431 |

## 关键行（错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
```

## 构建日志全文（共       90 行）

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
Build of product 'BilibiliClientiOS' complete! (73.82s)
Binary: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/arm64-apple-ios/release/BilibiliClientiOS
2026-10-03 14:15:43.377 AssetCatalogSimulatorAgent[6591:23819] The filter 'CIPortraitEffectSpillCorrection' is not implemented in the bundle at /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreImage/PortraitFilters.cifilter.
Wrote /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app/Info.plist
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app
No errors detected in compressed data of /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa.
-rw-r--r--  1 runner  staff   6.7M Oct  3 14:15 /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
Generated: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
-rw-r--r--  1 runner  staff  7022394 Oct  3 14:15 dist/ios/BilibiliClient-unsigned.ipa
Archive:  dist/ios/BilibiliClient-unsigned.ipa
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  10-03-2026 14:15   Payload/
        0  10-03-2026 14:15   Payload/BilibiliClient.app/
        0  10-03-2026 14:15   Payload/BilibiliClient.app/_CodeSignature/
     2498  10-03-2026 14:15   Payload/BilibiliClient.app/_CodeSignature/CodeResources
    14760  10-03-2026 14:15   Payload/BilibiliClient.app/Bilibiliclient76x76@2x~ipad.png
 18437232  10-03-2026 14:15   Payload/BilibiliClient.app/BilibiliClient
  2660264  10-03-2026 14:15   Payload/BilibiliClient.app/Assets.car
    10189  10-03-2026 14:15   Payload/BilibiliClient.app/Bilibiliclient60x60@2x.png
     2345  10-03-2026 14:15   Payload/BilibiliClient.app/Info.plist
--- 架构 ---
arm64
--- 构建平台 ---
/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.w1uIHLRM7D/Payload/BilibiliClient.app/BilibiliClient:
Load command 11
      cmd LC_BUILD_VERSION
  cmdsize 32
 platform IOS
    minos 26.0
      sdk 26.5
   ntools 1
--- Info.plist 关键键 ---
CFBundleShortVersionString = 1.9.5 
CFBundleVersion = 178 
MinimumOSVersion = 26.0 
CFBundleIcons = Dict {     CFBundlePrimaryIcon = Dict {         CFBundleIconFiles = Array { 
CFBundleIcons~ipad = Dict {     CFBundlePrimaryIcon = Dict {         CFBundleIconFiles = Array { 
--- 签名状态（应为未签名）---
Executable=/private/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.w1uIHLRM7D/Payload/BilibiliClient.app/BilibiliClient
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
  ok    两条播放路径共用收尾（进度/解码信息）仍在
  ok    自动播放开关仍在
  ok    动态评论区仍在
  ok    优先清晰度仍在
  ok    优先编码仍在
  ok    评论字号缩放仍在
  ok    菜单栏面板过滤

[4/4] 自动更新
  ok    Sparkle 默认 feed 不指向上游

结果：全部锚点在位（补丁完整）

=== 预发布资产复核（iOS） ===
total 13728
-rw-r--r--  1 runner  staff  7022394 Oct  3 14:16 BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
-rw-r--r--  1 runner  staff      115 Oct  3 14:16 BilibiliClient-1.9.5-ios-arm64-unsigned.ipa.sha256
iOS 预发布资产校验：OK（sha256=ea5f63b52c923d8a4e6518b1c3e97d60ccde39255923c7219519eeb6ca2ec210）
=== 复核结束 ===
```

## 产物

```
-rw-r--r--  1 runner  staff  7022394 Oct  3 14:15 dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
-rw-r--r--  1 runner  staff      115 Oct  3 14:15 dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa.sha256
ea5f63b52c923d8a4e6518b1c3e97d60ccde39255923c7219519eeb6ca2ec210  dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
```
