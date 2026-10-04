# CI 运行 #17（iOS arm64 未签名 IPA）— failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `0dfb06d01fb1cf7a18e63c72052cf51fe489d687` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| iOS SDK | /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37182084176 |

## 关键行（错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
7:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
11:     |                                `- error: cannot find type 'AVPlayer' in scope
14:=== 构建脚本退出码 rc=1；以下为诊断 ===
```

## 构建日志全文（共       40 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
[0/1] Planning build
Building for production...
[0/5] Write sources
[2/5] Write swift-version-7974D3F7F03D5E95.txt
[4/6] Compiling BilibiliClientCore AppDelegate.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/VideoDetail/VideoDetailView.swift:520:32: error: cannot find type 'AVPlayer' in scope
 518 |     /// 否则 AVPlayerView 被重建，AVKit 原生全屏会被一起踢出。
 519 |     /// 画面已移入分离窗口时由那个窗口承载，这里返回 `nil`。
 520 |     private var mountedPlayer: AVPlayer? {
     |                                `- error: cannot find type 'AVPlayer' in scope
 521 |         playbackWindow.isOpen ? nil : player.player
 522 |     }
=== 构建脚本退出码 rc=1；以下为诊断 ===
--- actool 复跑（脚本里它的 stdout 被 >/dev/null 吞掉）---
2026-10-04 06:12:29.058 AssetCatalogSimulatorAgent[2187:10263] The filter 'CIPortraitEffectSpillCorrection' is not implemented in the bundle at /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreImage/PortraitFilters.cifilter.
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.actool.compilation-results</key>
	<dict>
		<key>output-files</key>
		<array>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.JADY26ZRlt/Assets.car</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.JADY26ZRlt/Bilibiliclient60x60@2x.png</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.JADY26ZRlt/Bilibiliclient76x76@2x~ipad.png</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.JADY26ZRlt/partial.plist</string>
		</array>
	</dict>
</dict>
</plist>
total 5264
drwx------    6 runner  staff      192 Oct  4 06:12 .
drwx------@ 134 runner  staff     4288 Oct  4 06:12 ..
-rw-r--r--    1 runner  staff  2660264 Oct  4 06:12 Assets.car
-rw-r--r--    1 runner  staff    10189 Oct  4 06:12 Bilibiliclient60x60@2x.png
-rw-r--r--    1 runner  staff    14760 Oct  4 06:12 Bilibiliclient76x76@2x~ipad.png
-rw-r--r--    1 runner  staff      748 Oct  4 06:12 partial.plist
=== 诊断结束 ===
```

## 产物

```
(无)
```
