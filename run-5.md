# CI 运行 #5 — failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `2412a04045fa44ade578dbbd4b189f9429847110` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37116268159 |

## 关键行（SDK / 错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

## 构建日志开头（前 40 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
=== 构建脚本退出码 ��以下为诊断 ===
--- actool 版本与路径 ---
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
/usr/bin/actool
--- 图标资源 ---
total 0
drwxr-xr-x   3 runner  staff   96 Oct  3 10:23 .
drwxr-xr-x  19 runner  staff  608 Oct  3 10:26 ..
drwxr-xr-x   4 runner  staff  128 Oct  3 10:23 Bilibiliclient.icon
total 8
drwxr-xr-x  4 runner  staff   128 Oct  3 10:23 .
drwxr-xr-x  3 runner  staff    96 Oct  3 10:23 ..
drwxr-xr-x  3 runner  staff    96 Oct  3 10:23 Assets
-rw-r--r--  1 runner  staff  1508 Oct  3 10:23 icon.json

assets/Bilibiliclient.icon//Assets:
total 520
drwxr-xr-x  3 runner  staff      96 Oct  3 10:23 .
drwxr-xr-x  4 runner  staff     128 Oct  3 10:23 ..
-rw-r--r--  1 runner  staff  266105 Oct  3 10:23 未命名2 2.png
--- icon.json ---
{
  "fill" => {
    "solid" => "extended-gray:1.00000,1.00000"
  }
  "groups" => [
    0 => {
      "hidden" => false
      "layers" => [
        0 => {
          "blend-mode-specializations" => [
            0 => {
              "value" => "normal"
            }
            1 => {
              "appearance" => "dark"
```

## 构建日志全文（共       79 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
=== 构建脚本退出码 ��以下为诊断 ===
--- actool 版本与路径 ---
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
/usr/bin/actool
--- 图标资源 ---
total 0
drwxr-xr-x   3 runner  staff   96 Oct  3 10:23 .
drwxr-xr-x  19 runner  staff  608 Oct  3 10:26 ..
drwxr-xr-x   4 runner  staff  128 Oct  3 10:23 Bilibiliclient.icon
total 8
drwxr-xr-x  4 runner  staff   128 Oct  3 10:23 .
drwxr-xr-x  3 runner  staff    96 Oct  3 10:23 ..
drwxr-xr-x  3 runner  staff    96 Oct  3 10:23 Assets
-rw-r--r--  1 runner  staff  1508 Oct  3 10:23 icon.json

assets/Bilibiliclient.icon//Assets:
total 520
drwxr-xr-x  3 runner  staff      96 Oct  3 10:23 .
drwxr-xr-x  4 runner  staff     128 Oct  3 10:23 ..
-rw-r--r--  1 runner  staff  266105 Oct  3 10:23 未命名2 2.png
--- icon.json ---
{
  "fill" => {
    "solid" => "extended-gray:1.00000,1.00000"
  }
  "groups" => [
    0 => {
      "hidden" => false
      "layers" => [
        0 => {
          "blend-mode-specializations" => [
            0 => {
              "value" => "normal"
            }
            1 => {
              "appearance" => "dark"
              "value" => "normal"
            }
          ]
          "fill-specializations" => [
            0 => {
              "value" => {
                "linear-gradient" => [
                  0 => "display-p3:1.00000,0.48662,0.72363,1.00000"
                  1 => "display-p3:0.82635,0.40212,0.59797,1.00000"
                ]
              }
            }
            1 => {
              "appearance" => "dark"
              "value" => {
--- actool 复跑（不重定向，让报错露出来）---
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.actool.compilation-results</key>
	<dict>
		<key>output-files</key>
		<array>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.Bt5qETKfFO/Assets.car</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.Bt5qETKfFO/Bilibiliclient.icns</string>
			<string>/var/folders/36/tjdph2t965j8snz9_vkdnw0r0000gn/T/tmp.Bt5qETKfFO/partial.plist</string>
		</array>
	</dict>
</dict>
</plist>
--- 复跑产物 ---
total 3088
drwx------    5 runner  staff      160 Oct  3 10:26 .
drwx------@ 169 runner  staff     5408 Oct  3 10:26 ..
-rw-r--r--    1 runner  staff  1525432 Oct  3 10:26 Assets.car
-rw-r--r--    1 runner  staff    45592 Oct  3 10:26 Bilibiliclient.icns
-rw-r--r--    1 runner  staff      312 Oct  3 10:26 partial.plist
=== 诊断结束 ===
```

## 产物

```
(无)
```
