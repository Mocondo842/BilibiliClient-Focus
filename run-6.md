# CI 运行 #6 — success

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `a528b2102cacd91b87a1453ab10d0f456a740136` |
| 触发 | push by Mocondo842 |
| 结果 | **success** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37116775977 |

## 关键行（SDK / 错误）

```
14:+ echo 'Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'
15:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

## 构建日志开头（前 40 行）

```
+ set -euo pipefail
++ dirname ./scripts/build_app.sh
+ cd ./scripts/..
+ APP_NAME=BilibiliClient
+ CONFIG=release
++ cat version.txt
+ VERSION=1.9.5
++ git rev-list --count HEAD
+ BUILD=165
+ ICON_SOURCE=assets/Bilibiliclient.icon
+ ICON_NAME=Bilibiliclient
+ ACTOOL=/Applications/Xcode.app/Contents/Developer/usr/bin/actool
+ '[' -z /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk ']'
+ echo 'Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
+ mkdir -p Sources/BilibiliClientCore/Generated
+ cat
++ swift build -c release --product BilibiliClient --disable-sandbox
+ build_log='Fetching https://github.com/apple/swift-log.git
Fetching https://github.com/pointfreeco/swift-concurrency-extras
[1/1058] Fetching swift-concurrency-extras
[76/9290] Fetching swift-concurrency-extras, swift-log
Fetched https://github.com/apple/swift-log.git from cache (0.94s)
Fetched https://github.com/pointfreeco/swift-concurrency-extras from cache (0.94s)
Fetching https://github.com/kean/Nuke.git
Fetching https://github.com/gonzalezreal/swiftui-math
[1/1835] Fetching swiftui-math
[1836/38864] Fetching swiftui-math, nuke
Fetched https://github.com/kean/Nuke.git from cache (1.88s)
Fetched https://github.com/gonzalezreal/swiftui-math from cache (1.88s)
Fetching https://github.com/gonzalezreal/textual
Fetching https://github.com/sparkle-project/Sparkle
[1/2302] Fetching textual
[393/46464] Fetching textual, sparkle
Fetched https://github.com/sparkle-project/Sparkle from cache (2.87s)
Fetched https://github.com/gonzalezreal/textual from cache (2.87s)
Fetching https://github.com/apple/swift-collections.git
[1/28538] Fetching swift-collections
Fetched https://github.com/apple/swift-collections.git from cache (2.30s)
Computing version for https://github.com/apple/swift-log.git
```

## 构建日志全文（共      146 行）

```
+ set -euo pipefail
++ dirname ./scripts/build_app.sh
+ cd ./scripts/..
+ APP_NAME=BilibiliClient
+ CONFIG=release
++ cat version.txt
+ VERSION=1.9.5
++ git rev-list --count HEAD
+ BUILD=165
+ ICON_SOURCE=assets/Bilibiliclient.icon
+ ICON_NAME=Bilibiliclient
+ ACTOOL=/Applications/Xcode.app/Contents/Developer/usr/bin/actool
+ '[' -z /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk ']'
+ echo 'Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
+ mkdir -p Sources/BilibiliClientCore/Generated
+ cat
++ swift build -c release --product BilibiliClient --disable-sandbox
+ build_log='Fetching https://github.com/apple/swift-log.git
Fetching https://github.com/pointfreeco/swift-concurrency-extras
[1/1058] Fetching swift-concurrency-extras
[76/9290] Fetching swift-concurrency-extras, swift-log
Fetched https://github.com/apple/swift-log.git from cache (0.94s)
Fetched https://github.com/pointfreeco/swift-concurrency-extras from cache (0.94s)
Fetching https://github.com/kean/Nuke.git
Fetching https://github.com/gonzalezreal/swiftui-math
[1/1835] Fetching swiftui-math
[1836/38864] Fetching swiftui-math, nuke
Fetched https://github.com/kean/Nuke.git from cache (1.88s)
Fetched https://github.com/gonzalezreal/swiftui-math from cache (1.88s)
Fetching https://github.com/gonzalezreal/textual
Fetching https://github.com/sparkle-project/Sparkle
[1/2302] Fetching textual
[393/46464] Fetching textual, sparkle
Fetched https://github.com/sparkle-project/Sparkle from cache (2.87s)
Fetched https://github.com/gonzalezreal/textual from cache (2.87s)
Fetching https://github.com/apple/swift-collections.git
[1/28538] Fetching swift-collections
Fetched https://github.com/apple/swift-collections.git from cache (2.30s)
Computing version for https://github.com/apple/swift-log.git
Computed https://github.com/apple/swift-log.git at 1.15.1 (8.48s)
Computing version for https://github.com/apple/swift-collections.git
Computed https://github.com/apple/swift-collections.git at 1.6.0 (0.40s)
Computing version for https://github.com/gonzalezreal/textual
Computed https://github.com/gonzalezreal/textual at 0.5.0 (0.31s)
Computing version for https://github.com/sparkle-project/Sparkle
Computed https://github.com/sparkle-project/Sparkle at 2.10.0 (3.42s)
Computing version for https://github.com/kean/Nuke.git
Computed https://github.com/kean/Nuke.git at 12.9.0 (0.30s)
Computed https://github.com/apple/swift-log.git at 1.15.1 (0.00s)
Computed https://github.com/apple/swift-collections.git at 1.6.0 (0.00s)
Computed https://github.com/gonzalezreal/textual at 0.5.0 (0.00s)
Computed https://github.com/sparkle-project/Sparkle at 2.10.0 (0.00s)
Computed https://github.com/kean/Nuke.git at 12.9.0 (0.00s)
Computing version for https://github.com/gonzalezreal/swiftui-math
Computed https://github.com/gonzalezreal/swiftui-math at 0.1.0 (0.30s)
Computing version for https://github.com/pointfreeco/swift-concurrency-extras
Computed https://github.com/pointfreeco/swift-concurrency-extras at 1.4.1 (0.28s)
Creating working copy for https://github.com/sparkle-project/Sparkle
Working copy of https://github.com/sparkle-project/Sparkle resolved at 2.10.0
Creating working copy for https://github.com/pointfreeco/swift-concurrency-extras
Working copy of https://github.com/pointfreeco/swift-concurrency-extras resolved at 1.4.1
Creating working copy for https://github.com/gonzalezreal/textual
Working copy of https://github.com/gonzalezreal/textual resolved at 0.5.0
Creating working copy for https://github.com/apple/swift-collections.git
Working copy of https://github.com/apple/swift-collections.git resolved at 1.6.0
Creating working copy for https://github.com/kean/Nuke.git
Working copy of https://github.com/kean/Nuke.git resolved at 12.9.0
Creating working copy for https://github.com/gonzalezreal/swiftui-math
Working copy of https://github.com/gonzalezreal/swiftui-math resolved at 0.1.0
Creating working copy for https://github.com/apple/swift-log.git
Working copy of https://github.com/apple/swift-log.git resolved at 1.15.1
Downloading binary artifact https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-for-Swift-Package-Manager.zip
[32750/10193895] Downloading https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-for-Swift-Package-Manager.zip
Downloaded https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-for-Swift-Package-Manager.zip (0.78s)
Building for production...
[0/23] Copying prism-bundle.js
[1/23] Write sources
[9/23] Copying mathFonts.bundle
[10/23] Write sources
[19/23] Copying Sparkle.framework
[20/23] Write swift-version-7974D3F7F03D5E95.txt
[22/26] Compiling Logging MultiplexLogHandler.swift
[23/27] Compiling InternalCollectionsUtilities Debugging.swift
[24/28] Compiling ConcurrencyExtras ActorIsolated.swift
[25/29] Compiling Nuke Cache.swift
[26/30] Compiling OrderedCollections _HashTable+Bucket.swift
[27/31] Compiling _RopeModule BigString+Builder.swift
[28/32] Compiling HeapModule Heap+Descriptions.swift
[29/33] Compiling NukeUI FetchImage.swift
[30/34] Compiling ContainersPreview OutputSpan+Extras.swift
[31/35] Compiling BitCollections BinaryInteger extensions.swift
[32/36] Compiling HashTreeCollections _AncestorHashSlots.swift
[33/36] Compiling DequeModule Deque+Codable.swift
[34/37] Compiling Collections BitCollections reexports.swift
[35/37] Compiling SwiftUIMath Font.swift
[36/38] Compiling Textual Attachment.swift
[37/39] Compiling BilibiliClientCore AppDelegate.swift
[38/40] Compiling BilibiliClient BilibiliClientApp.swift
[38/40] Write Objects.LinkFileList
[39/40] Linking BilibiliClient
Build of product '\''BilibiliClient'\'' complete! (126.46s)'
++ pwd
+ OUT_DIR=/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist
+ APP_DIR=/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
+ rm -rf /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
+ mkdir -p /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/Resources
+ cp .build/release/BilibiliClient /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS/BilibiliClient
+ '[' release = release ']'
+ strip -x /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS/BilibiliClient
+ SPARKLE_SRC=.build/release/Sparkle.framework
+ '[' -d .build/release/Sparkle.framework ']'
+ mkdir -p /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/Frameworks
+ ditto .build/release/Sparkle.framework /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/Frameworks/Sparkle.framework
+ otool -l /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS/BilibiliClient
+ grep -q @executable_path/../Frameworks
+ install_name_tool -add_rpath @executable_path/../Frameworks /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/MacOS/BilibiliClient
+ echo 'Embedded: Sparkle.framework'
Embedded: Sparkle.framework
++ mktemp -d
+ ICON_BUILD_DIR=/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.eg6npupgpQ
+ /Applications/Xcode.app/Contents/Developer/usr/bin/actool --compile /var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.eg6npupgpQ --platform macosx --minimum-deployment-target 26.0 --app-icon Bilibiliclient --output-partial-info-plist /var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.eg6npupgpQ/partial.plist assets/Bilibiliclient.icon
+ test -f /var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.eg6npupgpQ/Assets.car
+ cp /var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.eg6npupgpQ/Assets.car /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/Resources/Assets.car
+ SPARKLE_FEED_URL=https://example.invalid/bilibiliclient-fork/appcast.xml
+ SPARKLE_PUBLIC_KEY=9cFE7AG3SzRLHsDfRsNHfPJeJ8Za/oH6Yrz4kYGoUwQ=
+ SPARKLE_ATS=
+ case "$SPARKLE_FEED_URL" in
+ cat
+ '[' -z - ']'
+ '[' -n - ']'
+ '[' -d /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/Frameworks ']'
+ codesign --force --deep --sign - /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app/Contents/Frameworks/Sparkle.framework
+ codesign --force --sign - /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
+ echo 'Signed with: -'
Signed with: -
+ echo 'Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app'
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
+ '[' 1 = 1 ']'
+ ARCHIVE_DIR=dist/archive/1.9.5
+ mkdir -p dist/archive/1.9.5
+ ARCHIVE=dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip
+ ditto -c -k --keepParent /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip
+ echo 'Archived: dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip'
Archived: dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip
+ '[' 1 '!=' 1 ']'
```

## 产物

```
-rw-r--r--  1 runner  staff  5449333 Oct  3 10:35 dist/BilibiliClient-1.9.5-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  3 10:35 dist/BilibiliClient-1.9.5-macos-arm64.app.zip.sha256
```
