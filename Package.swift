// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BilibiliClient",
    platforms: [.macOS(.v26)],
    dependencies: [
        // 图片加载：后台解码 + 按尺寸降采样、预取、可见性优先级与取消、两级缓存
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
        // 自动更新：EdDSA 签名校验的 appcast + 增量更新（macOS 12+）
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.10.0"),
        // SwiftUI 显示层补齐：材质/模糊、GeometryReader 增强、AppKit 桥接等
        .package(url: "https://github.com/SwiftUIX/SwiftUIX", from: "0.3.0"),
        // 富文本渲染：评论 / 动态 / 简介里的链接、@、表情按 AttributedString 排版
        .package(url: "https://github.com/gonzalezreal/textual", from: "0.3.0"),
        // 数据结构：Deque 是真正的双端队列，直播弹幕缓冲的出队从 O(n) 降到 O(1)
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.6.0"),
        // 日志门面：统一入口接到系统 os_log（后端见 Core/Support/Logging.swift）
        .package(url: "https://github.com/apple/swift-log.git", from: "1.15.1"),
    ],
    targets: [
        .executableTarget(
            name: "BilibiliClient",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "SwiftUIX", package: "SwiftUIX"),
                .product(name: "Textual", package: "textual"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/BilibiliClient"
        )
    ],
    swiftLanguageModes: [.v5]
)
