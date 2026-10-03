# CI 运行 #10（iOS arm64 未签名 IPA）— success

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `2b34dfded9c1eb5e434b126123741c3850483431` |
| 触发 | push by Mocondo842 |
| 结果 | **success** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| iOS SDK | /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37119278250 |

## 关键行（错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
```

## 构建日志全文（共       80 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
Fetching https://github.com/sparkle-project/Sparkle
Fetching https://github.com/gonzalezreal/textual
[1/2302] Fetching textual
[439/46464] Fetching textual, sparkle
Fetched https://github.com/gonzalezreal/textual from cache (2.81s)
Fetched https://github.com/sparkle-project/Sparkle from cache (2.81s)
Fetching https://github.com/apple/swift-collections.git
Fetching https://github.com/pointfreeco/swift-concurrency-extras
[1/1058] Fetching swift-concurrency-extras
[1059/29596] Fetching swift-concurrency-extras, swift-collections
Fetched https://github.com/pointfreeco/swift-concurrency-extras from cache (2.18s)
Fetched https://github.com/apple/swift-collections.git from cache (2.18s)
Fetching https://github.com/kean/Nuke.git
Fetching https://github.com/gonzalezreal/swiftui-math
[1/1835] Fetching swiftui-math
[1836/38864] Fetching swiftui-math, nuke
Fetched https://github.com/kean/Nuke.git from cache (2.23s)
Fetched https://github.com/gonzalezreal/swiftui-math from cache (2.23s)
Fetching https://github.com/apple/swift-log.git
[1/8232] Fetching swift-log
Fetched https://github.com/apple/swift-log.git from cache (1.03s)
Creating working copy for https://github.com/gonzalezreal/textual
Creating working copy for https://github.com/apple/swift-collections.git
Creating working copy for https://github.com/pointfreeco/swift-concurrency-extras
Working copy of https://github.com/pointfreeco/swift-concurrency-extras resolved at 1.4.1
Creating working copy for https://github.com/kean/Nuke.git
Working copy of https://github.com/gonzalezreal/textual resolved at 0.5.0
Creating working copy for https://github.com/gonzalezreal/swiftui-math
Working copy of https://github.com/kean/Nuke.git resolved at 12.9.0
Working copy of https://github.com/apple/swift-collections.git resolved at 1.6.0
Creating working copy for https://github.com/apple/swift-log.git
Creating working copy for https://github.com/sparkle-project/Sparkle
Working copy of https://github.com/gonzalezreal/swiftui-math resolved at 0.1.0
Working copy of https://github.com/apple/swift-log.git resolved at 1.15.1
Working copy of https://github.com/sparkle-project/Sparkle resolved at 2.10.0
Downloading binary artifact https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-for-Swift-Package-Manager.zip
[32750/10193895] Downloading https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-for-Swift-Package-Manager.zip
Downloaded https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-for-Swift-Package-Manager.zip (1.15s)
Building for production...
[0/22] Copying prism-bundle.js
[1/22] Write sources
[8/22] Copying mathFonts.bundle
[8/22] Write sources
[19/22] Write swift-version-7974D3F7F03D5E95.txt
[21/25] Compiling Logging MultiplexLogHandler.swift
[22/26] Compiling InternalCollectionsUtilities Debugging.swift
[23/27] Compiling ConcurrencyExtras ActorIsolated.swift
[24/28] Compiling Nuke Cache.swift
[25/29] Compiling _RopeModule BigString+Builder.swift
[26/30] Compiling OrderedCollections _HashTable+Bucket.swift
[27/31] Compiling HeapModule Heap+Descriptions.swift
[28/32] Compiling NukeUI FetchImage.swift
[29/33] Compiling ContainersPreview OutputSpan+Extras.swift
[30/34] Compiling BitCollections BinaryInteger extensions.swift
[31/35] Compiling HashTreeCollections _AncestorHashSlots.swift
[32/35] Compiling DequeModule Deque+Codable.swift
[33/36] Compiling Collections BitCollections reexports.swift
[34/36] Compiling SwiftUIMath Font.swift
[35/37] Compiling Textual Attachment.swift
[36/38] Compiling BilibiliClientCore AppDelegate.swift
[37/39] Compiling BilibiliClientiOS BilibiliClientiOSApp.swift
[37/39] Write Objects.LinkFileList
clang: warning: using sysroot for 'MacOSX' but targeting 'iPhone' [-Wincompatible-sysroot]
[38/39] Linking BilibiliClientiOS
Build of product 'BilibiliClientiOS' complete! (117.50s)
Binary: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/.build/arm64-apple-ios/release/BilibiliClientiOS
2026-10-03 11:25:58.945 AssetCatalogSimulatorAgent[35021:88706] The filter 'CIPortraitEffectSpillCorrection' is not implemented in the bundle at /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreImage/PortraitFilters.cifilter.
Wrote /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app/Info.plist
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient.app
No errors detected in compressed data of /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa.
-rw-r--r--  1 runner  staff   6.7M Oct  3 11:26 /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa
Generated: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/ios/BilibiliClient-unsigned.ipa

=== 预发布资产复核（iOS） ===
total 13672
-rw-r--r--  1 runner  staff  6994581 Oct  3 11:26 BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
-rw-r--r--  1 runner  staff      115 Oct  3 11:26 BilibiliClient-1.9.5-ios-arm64-unsigned.ipa.sha256
iOS 预发布资产校验：OK（sha256=9abc31d859d2e7d1e673c09b2fc424aef1f1539fcaf4d873313b41f4c4a8a4eb）
=== 复核结束 ===
```

## 产物

```
-rw-r--r--  1 runner  staff  6994581 Oct  3 11:26 dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
-rw-r--r--  1 runner  staff      115 Oct  3 11:26 dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa.sha256
9abc31d859d2e7d1e673c09b2fc424aef1f1539fcaf4d873313b41f4c4a8a4eb  dist/BilibiliClient-1.9.5-ios-arm64-unsigned.ipa
```
