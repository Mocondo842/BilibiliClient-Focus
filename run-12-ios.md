# CI 运行 #12（iOS arm64 未签名 IPA）— failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `9891416a09bc72678cdf93d52617f7d30e6e68fb` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| iOS SDK | /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37122726085 |

## 关键行（错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
7:/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/Player/PlayerController.swift:266:17: error: expression is 'async' but is not marked with 'await'
11:    |                 |- error: expression is 'async' but is not marked with 'await'
15:=== 构建脚本退出码 rc=1；以下为诊断 ===
```

## 构建日志全文（共       41 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk (arm64-apple-ios26.0)
[0/1] Planning build
Building for production...
[0/5] Write sources
[2/5] Write swift-version-7974D3F7F03D5E95.txt
[4/6] Compiling BilibiliClientCore AppDelegate.swift
/Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/Sources/BilibiliClientCore/Features/Player/PlayerController.swift:266:17: error: expression is 'async' but is not marked with 'await'
264 |             player?.play()
265 |             if let resume = pendingResume, resume > 1 {
266 |                 player?.seek(to: CMTime(seconds: resume, preferredTimescale: 600),
    |                 |- error: expression is 'async' but is not marked with 'await'
    |                 `- note: call is 'async'
267 |                              toleranceBefore: .zero,
268 |                              toleranceAfter: .zero)
=== 构建脚本退出码 rc=1；以下为诊断 ===
--- actool 复跑（脚本里它的 stdout 被 >/dev/null 吞掉）---
2026-10-03 12:24:42.926 AssetCatalogSimulatorAgent[8189:28150] The filter 'CIPortraitEffectSpillCorrection' is not implemented in the bundle at /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot/System/Library/CoreImage/PortraitFilters.cifilter.
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.actool.compilation-results</key>
	<dict>
		<key>output-files</key>
		<array>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.icoe0QdTkv/Assets.car</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.icoe0QdTkv/Bilibiliclient60x60@2x.png</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.icoe0QdTkv/Bilibiliclient76x76@2x~ipad.png</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.icoe0QdTkv/partial.plist</string>
		</array>
	</dict>
</dict>
</plist>
total 5264
drwx------    6 runner  staff      192 Oct  3 12:24 .
drwx------@ 166 runner  staff     5312 Oct  3 12:24 ..
-rw-r--r--    1 runner  staff  2660264 Oct  3 12:24 Assets.car
-rw-r--r--    1 runner  staff    10189 Oct  3 12:24 Bilibiliclient60x60@2x.png
-rw-r--r--    1 runner  staff    14760 Oct  3 12:24 Bilibiliclient76x76@2x~ipad.png
-rw-r--r--    1 runner  staff      748 Oct  3 12:24 partial.plist
=== 诊断结束 ===
```

## 产物

```
(无)
```
