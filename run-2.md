# CI 运行 #2 — failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `0a5058c5b23692d9f81920cd8483de68d4aa27bb` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37114449407 |

## 关键行（SDK / 错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
553:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
557:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
563:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
567:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
573:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
577:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
583:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
587:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
593:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
597:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
603:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
607:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
613:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
617:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
623:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
627:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
633:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
637:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
643:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
647:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
653:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
657:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
663:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
667:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
673:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
677:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
683:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
687:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
693:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
697:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
703:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
707:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
713:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
717:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
723:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
727:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
733:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
737:   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
743:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
```

## 构建日志开头（前 40 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Release build failed, 回退到 debug 构建...
Building for debugging...
[0/25] Copying prism-bundle.js
[0/25] Write sources
[18/25] Copying mathFonts.bundle
[19/25] Write BilibiliClient-entitlement.plist
[20/25] Copying Sparkle.framework
[21/25] Write swift-version-7974D3F7F03D5E95.txt
[23/103] Compiling Nuke DataPublisher.swift
[24/103] Compiling Nuke Extensions.swift
[25/103] Compiling Nuke Graphics.swift
[26/103] Compiling Nuke ImagePublisher.swift
[27/106] Emitting module Logging
[28/106] Compiling Nuke ImageRequestKeys.swift
[29/106] Compiling Nuke LinkedList.swift
[30/106] Compiling Nuke Log.swift
[31/106] Compiling Nuke Operation.swift
[32/106] Compiling Logging Logger.swift
[33/106] Compiling Logging LoggingSystem.swift
[34/106] Compiling Logging MetadataProvider.swift
[35/120] Emitting module InternalCollectionsUtilities
[36/120] Compiling InternalCollectionsUtilities Debugging.swift
[37/120] Compiling InternalCollectionsUtilities Descriptions.swift
[38/120] Compiling InternalCollectionsUtilities FixedWidthInteger+roundUpToPowerOfTwo.swift
[39/120] Compiling InternalCollectionsUtilities Integer rank.swift
[40/120] Compiling InternalCollectionsUtilities UInt+first and last set bit.swift
[41/120] Compiling InternalCollectionsUtilities UInt+reversed.swift
[42/120] Compiling InternalCollectionsUtilities LifetimeOverride.swift
[43/120] Compiling InternalCollectionsUtilities RandomAccessCollection+Offsets.swift
[44/120] Compiling InternalCollectionsUtilities Span+Extras.swift
[45/120] Compiling InternalCollectionsUtilities String+Padding.swift
[46/120] Compiling InternalCollectionsUtilities _UnsafeBitSet+Index.swift
[47/120] Compiling InternalCollectionsUtilities _UnsafeBitSet+_Word.swift
[48/120] Compiling InternalCollectionsUtilities _UnsafeBitSet.swift
[49/126] Compiling InternalCollectionsUtilities UnsafeBufferPointer+Extras.swift
[50/126] Compiling InternalCollectionsUtilities UnsafeMutableBufferPointer+Extras.swift
[51/126] Compiling InternalCollectionsUtilities UnsafeMutableRawBufferPointer+Extras.swift
[52/126] Compiling InternalCollectionsUtilities UnsafeRawBufferPointer+Extras.swift
[53/126] Compiling InternalCollectionsUtilities _SortedCollection.swift
```

## 构建日志尾部（最后 120 行）

```
   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
   |                                                                                            |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
   |                                                                                            `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
47 |         return item.modules.moduleDynamic != nil || item.orig != nil
48 |     }
[779/810] Compiling BilibiliClientCore DownloadPlanner.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
44 |     static func keeps(_ item: DynamicItem) -> Bool {
45 |         if blockedItemTypes.contains(item.type) { return false }
46 |         if let major = item.modules.moduleDynamic?.major, blockedMajorTypes.contains(major.type) { return false }
   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
   |                                                                                            |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
   |                                                                                            `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
47 |         return item.modules.moduleDynamic != nil || item.orig != nil
48 |     }
[780/810] Compiling BilibiliClientCore DynamicDetailView.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
44 |     static func keeps(_ item: DynamicItem) -> Bool {
45 |         if blockedItemTypes.contains(item.type) { return false }
46 |         if let major = item.modules.moduleDynamic?.major, blockedMajorTypes.contains(major.type) { return false }
   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
   |                                                                                            |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
   |                                                                                            `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
47 |         return item.modules.moduleDynamic != nil || item.orig != nil
48 |     }
[781/810] Compiling BilibiliClientCore DynamicFeedView.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
44 |     static func keeps(_ item: DynamicItem) -> Bool {
45 |         if blockedItemTypes.contains(item.type) { return false }
46 |         if let major = item.modules.moduleDynamic?.major, blockedMajorTypes.contains(major.type) { return false }
   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
   |                                                                                            |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
   |                                                                                            `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
47 |         return item.modules.moduleDynamic != nil || item.orig != nil
48 |     }
[782/810] Compiling BilibiliClientCore DynamicService.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/DeRecommend/DeRecommendation.swift:46:92: error: value of optional type 'String?' must be unwrapped to a value of type 'String'
44 |     static func keeps(_ item: DynamicItem) -> Bool {
45 |         if blockedItemTypes.contains(item.type) { return false }
46 |         if let major = item.modules.moduleDynamic?.major, blockedMajorTypes.contains(major.type) { return false }
   |                                                                                            |- error: value of optional type 'String?' must be unwrapped to a value of type 'String'
   |                                                                                            |- note: coalesce using '??' to provide a default when the optional value contains 'nil'
   |                                                                                            `- note: force-unwrap using '!' to abort execution if the optional value contains 'nil'
47 |         return item.modules.moduleDynamic != nil || item.orig != nil
48 |     }
[783/860] Compiling BilibiliClientCore AuthService.swift
[784/860] Compiling BilibiliClientCore SessionStore.swift
[785/860] Compiling BilibiliClientCore Formatters.swift
[786/860] Compiling BilibiliClientCore Logging.swift
[787/860] Compiling BilibiliClientCore NSEventMonitor.swift
[788/860] Compiling BilibiliClientCore PlatformTypes+App.swift
[789/860] Compiling BilibiliClientCore PullToRefresh.swift
[790/860] Compiling BilibiliClientCore DanmakuAsyncLayer.swift
[791/860] Compiling BilibiliClientCore DanmakuCell.swift
[792/860] Compiling BilibiliClientCore DanmakuCellModel.swift
[793/860] Compiling BilibiliClientCore DanmakuQueuePool.swift
[794/860] Compiling BilibiliClientCore DanmakuTrack.swift
[795/860] Compiling BilibiliClientCore DanmakuView.swift
[796/860] Compiling BilibiliClientCore PlatformTypes.swift
[797/860] Compiling BilibiliClientCore DanmakuViewAdapter.swift
[798/860] Compiling BilibiliClientCore BiliImages.swift
[799/860] Compiling BilibiliClientCore CornerRadius.swift
[800/860] Compiling BilibiliClientCore Glass.swift
[801/860] Compiling BilibiliClientCore GlassSearchField.swift
[802/860] Compiling BilibiliClientCore MediaListRow.swift
[803/860] Compiling BilibiliClientCore Motion.swift
[804/860] Compiling BilibiliClientCore RemoteImage.swift
[805/860] Compiling BilibiliClientCore RichText.swift
[806/860] Compiling BilibiliClientCore SharedViews.swift
[807/860] Compiling BilibiliClientCore VideoCardView.swift
[808/860] Compiling BilibiliClientCore FeedService.swift
[809/860] Compiling BilibiliClientCore HomeService.swift
[810/860] Compiling BilibiliClientCore PartitionVideosView.swift
[811/860] Compiling BilibiliClientCore PopularView.swift
[812/860] Compiling BilibiliClientCore RecommendView.swift
[813/860] Compiling BilibiliClientCore ZonesView.swift
[814/860] Compiling BilibiliClientCore FavoritesView.swift
[815/860] Compiling BilibiliClientCore HistoryReporter.swift
[816/860] Compiling BilibiliClientCore HistoryView.swift
[817/860] Compiling BilibiliClientCore LibraryService.swift
[818/860] Compiling BilibiliClientCore WatchLaterView.swift
[819/860] Compiling BilibiliClientCore LiveDanmakuEngine.swift
[820/860] Compiling BilibiliClientCore LiveDetailView.swift
[821/860] Compiling BilibiliClientCore LiveFeedView.swift
[822/860] Compiling BilibiliClientCore LivePlayerModel.swift
[823/860] Compiling BilibiliClientCore LivePlayerSurface.swift
[824/860] Compiling BilibiliClientCore LiveService.swift
[825/860] Compiling BilibiliClientCore HLSProxy.swift
[826/860] Compiling BilibiliClientCore IOSPlayerSurface.swift
[827/860] Compiling BilibiliClientCore MP4FragmentParser.swift
[828/860] Compiling BilibiliClientCore PlayerControlBar.swift
[829/860] Compiling BilibiliClientCore PlayerController.swift
[830/860] Compiling BilibiliClientCore PlayerPresentationState.swift
[831/860] Compiling BilibiliClientCore PlayerSurfaceView.swift
[832/860] Compiling BilibiliClientCore PlayerWindow.swift
[833/860] Compiling BilibiliClientCore SIDXParser.swift
[834/860] Compiling BilibiliClientCore SystemMediaCenter.swift
[835/860] Compiling BilibiliClientCore VideoPlayerSurface.swift
[836/860] Compiling BilibiliClientCore AccountPanelView.swift
[837/860] Compiling BilibiliClientCore LoginView.swift
[838/860] Compiling BilibiliClientCore RelationService.swift
[839/860] Compiling BilibiliClientCore UpProfileView.swift
[840/860] Compiling BilibiliClientCore UpService.swift
[841/860] Compiling BilibiliClientCore SearchService.swift
[842/860] Compiling BilibiliClientCore SearchView.swift
[843/860] Compiling BilibiliClientCore SettingsView.swift
[844/860] Compiling BilibiliClientCore SponsorBlockService.swift
[845/860] Compiling BilibiliClientCore SponsorNoticeCard.swift
[846/860] Compiling BilibiliClientCore SponsorNoticeHostView.swift
[847/860] Compiling BilibiliClientCore SponsorSegment.swift
[848/860] Compiling BilibiliClientCore SponsorSkipEngine.swift
[849/860] Compiling BilibiliClientCore UserActionService.swift
[850/860] Compiling BilibiliClientCore VideoDetailView.swift
[851/860] Compiling BilibiliClientCore VideoService.swift
[852/860] Compiling BilibiliClientCore BuildInfo.generated.swift
[853/860] Compiling BilibiliClientCore Models.swift
[854/860] Compiling BilibiliClientCore APIClient.swift
[855/860] Compiling BilibiliClientCore BiliCookies.swift
[856/860] Compiling BilibiliClientCore KeychainStore.swift
[857/860] Compiling BilibiliClientCore WBISigner.swift
```

## 产物

```
(无)
```
