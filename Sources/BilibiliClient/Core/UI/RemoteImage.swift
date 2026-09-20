import NukeUI
import SwiftUI

/// 远程图片视图（Nuke 驱动）。
///
/// `AsyncImage` 不保留解码结果、视图一重建就重新请求；这里交给 Nuke 的管线：
/// 后台解码、两级缓存（内存 + 磁盘）、同 URL 并发合并、离开视野自动取消。
/// 传进来的地址会按 `variant` 拼上图床尺寸后缀，服务端直接下发显示尺寸的图。
struct RemoteImage: View {
    let url: URL?
    /// 采用途决定请求尺寸（头像 / 封面 / 大图 / 保持比例）
    var variant: Formatters.ImageVariant = .card

    var body: some View {
        LazyImage(url: Formatters.sized(url, variant)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.quaternary.opacity(0.55))
            }
        }
    }
}
