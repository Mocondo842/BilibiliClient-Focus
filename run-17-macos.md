# CI 运行 #17（macOS arm64）— failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `0dfb06d01fb1cf7a18e63c72052cf51fe489d687` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37182084176 |

## 关键行（SDK / 错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
550:error: emit-module command failed with exit code 1 (use -v to see invocation)
552:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
556:     |                                `- error: cannot find type 'AVPlayer' in scope
602:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
606:     |                                `- error: cannot find type 'AVPlayer' in scope
610:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
614:     |                                `- error: cannot find type 'AVPlayer' in scope
618:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
622:     |                                `- error: cannot find type 'AVPlayer' in scope
626:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
630:     |                                `- error: cannot find type 'AVPlayer' in scope
634:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
638:     |                                `- error: cannot find type 'AVPlayer' in scope
642:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
646:     |                                `- error: cannot find type 'AVPlayer' in scope
650:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
654:     |                                `- error: cannot find type 'AVPlayer' in scope
658:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
662:     |                                `- error: cannot find type 'AVPlayer' in scope
666:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
670:     |                                `- error: cannot find type 'AVPlayer' in scope
674:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
678:     |                                `- error: cannot find type 'AVPlayer' in scope
682:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
686:     |                                `- error: cannot find type 'AVPlayer' in scope
690:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
694:     |                                `- error: cannot find type 'AVPlayer' in scope
698:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
702:     |                                `- error: cannot find type 'AVPlayer' in scope
706:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
710:     |                                `- error: cannot find type 'AVPlayer' in scope
714:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
718:     |                                `- error: cannot find type 'AVPlayer' in scope
722:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
726:     |                                `- error: cannot find type 'AVPlayer' in scope
730:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
734:     |                                `- error: cannot find type 'AVPlayer' in scope
738:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
742:     |                                `- error: cannot find type 'AVPlayer' in scope
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
[23/103] Compiling Nuke ImageRequestKeys.swift
[24/103] Compiling Nuke LinkedList.swift
[25/103] Compiling Nuke Log.swift
[26/103] Compiling Nuke Operation.swift
[27/106] Emitting module Logging
[28/106] Compiling Nuke DataPublisher.swift
[29/106] Compiling Nuke Extensions.swift
[30/106] Compiling Nuke Graphics.swift
[31/106] Compiling Nuke ImagePublisher.swift
[32/106] Compiling Logging Logger.swift
[33/106] Compiling Logging LoggingSystem.swift
[34/106] Compiling Logging MetadataProvider.swift
[35/120] Compiling InternalCollectionsUtilities Debugging.swift
[36/120] Compiling InternalCollectionsUtilities Descriptions.swift
[37/120] Compiling InternalCollectionsUtilities FixedWidthInteger+roundUpToPowerOfTwo.swift
[38/120] Compiling InternalCollectionsUtilities Integer rank.swift
[39/120] Compiling InternalCollectionsUtilities UInt+first and last set bit.swift
[40/120] Compiling InternalCollectionsUtilities UInt+reversed.swift
[41/120] Compiling InternalCollectionsUtilities LifetimeOverride.swift
[42/120] Emitting module InternalCollectionsUtilities
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

## 构建日志尾部（最后 150 行，全文      810 行）

```
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[808/864] Compiling BilibiliClientCore PlaybackProgressStore.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[809/864] Compiling BilibiliClientCore SessionFallbackStore.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[810/864] Compiling BilibiliClientCore BuildInfo.generated.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[811/864] Compiling BilibiliClientCore Models.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[812/864] Compiling BilibiliClientCore APIClient.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[813/864] Compiling BilibiliClientCore BiliCookies.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[814/864] Compiling BilibiliClientCore KeychainStore.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[815/864] Compiling BilibiliClientCore WBISigner.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[816/864] Compiling BilibiliClientCore AuthService.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[817/864] Compiling BilibiliClientCore SessionStore.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[818/864] Compiling BilibiliClientCore Formatters.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[819/864] Compiling BilibiliClientCore Logging.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[820/864] Compiling BilibiliClientCore NSEventMonitor.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
[821/864] Compiling BilibiliClientCore PlatformTypes+App.swift
[822/864] Compiling BilibiliClientCore PullToRefresh.swift
[823/864] Compiling BilibiliClientCore DanmakuAsyncLayer.swift
[824/864] Compiling BilibiliClientCore DanmakuCell.swift
[825/864] Compiling BilibiliClientCore DanmakuCellModel.swift
[826/864] Compiling BilibiliClientCore DanmakuQueuePool.swift
[827/864] Compiling BilibiliClientCore DanmakuTrack.swift
[828/864] Compiling BilibiliClientCore DanmakuView.swift
[829/864] Compiling BilibiliClientCore PlatformTypes.swift
[830/864] Compiling BilibiliClientCore DanmakuViewAdapter.swift
[831/864] Compiling BilibiliClientCore BiliImages.swift
[832/864] Compiling BilibiliClientCore CornerRadius.swift
[833/864] Compiling BilibiliClientCore Glass.swift
[834/864] Compiling BilibiliClientCore GlassSearchField.swift
[835/864] Compiling BilibiliClientCore MediaListRow.swift
[836/864] Compiling BilibiliClientCore Motion.swift
[837/864] Compiling BilibiliClientCore RemoteImage.swift
[838/864] Compiling BilibiliClientCore RichText.swift
[839/864] Compiling BilibiliClientCore SharedViews.swift
[840/864] Compiling BilibiliClientCore VideoCardView.swift
[841/864] Compiling BilibiliClientCore HLSProxy.swift
[842/864] Compiling BilibiliClientCore IOSPlayerSurface.swift
[843/864] Compiling BilibiliClientCore MP4FragmentParser.swift
[844/864] Compiling BilibiliClientCore PlayerControlBar.swift
[845/864] Compiling BilibiliClientCore PlayerController.swift
[846/864] Compiling BilibiliClientCore PlayerPresentationState.swift
[847/864] Compiling BilibiliClientCore PlayerSurfaceView.swift
[848/864] Compiling BilibiliClientCore PlayerWindow.swift
[849/864] Compiling BilibiliClientCore SIDXParser.swift
[850/864] Compiling BilibiliClientCore SystemMediaCenter.swift
[851/864] Compiling BilibiliClientCore VideoPlayerSurface.swift
[852/864] Compiling BilibiliClientCore AccountPanelView.swift
[853/864] Compiling BilibiliClientCore LoginView.swift
[854/864] Compiling BilibiliClientCore RelationService.swift
[855/864] Compiling BilibiliClientCore UpProfileView.swift
[856/864] Compiling BilibiliClientCore UpService.swift
[857/864] Compiling BilibiliClientCore SearchService.swift
[858/864] Compiling BilibiliClientCore SearchView.swift
[859/864] Compiling BilibiliClientCore SettingsView.swift
[860/864] Compiling BilibiliClientCore SponsorBlockService.swift
[861/864] Compiling BilibiliClientCore SponsorNoticeCard.swift
=== 构建脚本退出码 rc=1；以下为诊断 ===
```

## 产物

```
(无)
```
