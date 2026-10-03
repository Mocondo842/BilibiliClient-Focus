# CI 运行 #8 — failure

| 项 | 值 |
|---|---|
| 分支 / 提交 | `derec-layout` @ `68c1ca6a4267449e61dfd0d9d9d66fc94e9a8916` |
| 触发 | push by Mocondo842 |
| 结果 | **failure** |
| Runner | arm64 / macOS 26.6.2 |
| Xcode | Xcode 26.6 Build version 17F113  |
| Swift | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) |
| Run 页面 | https://github.com/Mocondo842/BilibiliClient-Focus/actions/runs/37118265400 |

## 关键行（SDK / 错误）

```
1:Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
```

## 构建日志开头（前 40 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
Signed with: -
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
Archived: dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip

=== 预发布资产复核（在 runner 上把刚上传的东西拉回来） ===
total 10656
-rw-r--r--  1 runner  staff  5449342 Oct  3 11:02 BilibiliClient-1.9.5-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  3 11:02 BilibiliClient-1.9.5-macos-arm64.app.zip.sha256
/Users/runner/work/_temp/ea0d91b4-0b0c-4b6c-b334-c23570f5d344.sh: line 11: ACTUAL�: unbound variable
```

## 构建日志全文（共       11 行）

```
Using SDK: /Applications/Xcode_26.6.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
Embedded: Sparkle.framework
Signed with: -
Built: /Users/runner/work/BilibiliClient-Focus/BilibiliClient-Focus/dist/BilibiliClient.app
Archived: dist/archive/1.9.5/BilibiliClient-v1.9.5.app.zip

=== 预发布资产复核（在 runner 上把刚上传的东西拉回来） ===
total 10656
-rw-r--r--  1 runner  staff  5449342 Oct  3 11:02 BilibiliClient-1.9.5-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  3 11:02 BilibiliClient-1.9.5-macos-arm64.app.zip.sha256
/Users/runner/work/_temp/ea0d91b4-0b0c-4b6c-b334-c23570f5d344.sh: line 11: ACTUAL�: unbound variable
```

## 产物

```
-rw-r--r--  1 runner  staff  5449342 Oct  3 11:02 dist/BilibiliClient-1.9.5-macos-arm64.app.zip
-rw-r--r--  1 runner  staff      112 Oct  3 11:02 dist/BilibiliClient-1.9.5-macos-arm64.app.zip.sha256
eca1faa9875ba547bf4db45c4e833f43b39088199140b49e25ce5a89f27d47df  dist/BilibiliClient-1.9.5-macos-arm64.app.zip
```
