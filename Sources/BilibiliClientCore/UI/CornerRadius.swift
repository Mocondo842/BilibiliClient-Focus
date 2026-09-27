import SwiftUI

/// `cornerRadius(_:style:)` 的本地实现。
///
/// 背景：这个修饰符原本来自 SwiftUIX，但 SwiftUIX 在 iOS SDK 下编译不过
/// （`ForEach++.swift` 的泛型扩展会触发编译器 “failed to produce diagnostic”），
/// 而整个项目对 SwiftUIX 的依赖就只有这一个 API。SwiftUIX 的实现本身就是
///   `clipShape(RoundedRectangle(cornerRadius: radius, style: style))`
/// 这里照抄同一行，渲染结果与原来逐像素一致。
extension View {
    func cornerRadius(_ radius: CGFloat, style: RoundedCornerStyle) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: style))
    }
}
