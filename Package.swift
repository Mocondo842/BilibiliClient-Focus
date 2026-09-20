// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BilibiliClient",
    platforms: [.macOS(.v26)],
    dependencies: [
        // 图片加载：后台解码 + 按尺寸降采样、预取、可见性优先级与取消、两级缓存
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "BilibiliClient",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
            ],
            path: "Sources/BilibiliClient"
        )
    ],
    swiftLanguageModes: [.v5]
)
