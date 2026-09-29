import SwiftUI

/// 下拉刷新的统一入口。各信息流都是自定义排版的 `ScrollView`，塞不进 `List`，
/// 所以两端要用不同机制：
///
/// - **macOS**：SwiftUI 的 `.refreshable` 挂在 `ScrollView` 上就能用，**保持原样**。
/// - **iOS / iPadOS**：`.refreshable` 只对 `List` / `Form` 生效，`ScrollView` 上拿不到
///   刷新控件。这里把系统的 `UIRefreshControl` 直接装到底层 `UIScrollView` 上——
///   `List` 用的就是同一个控件，拉拽手感与动画完全一致。
extension View {
    @ViewBuilder
    func feedRefreshable(_ action: @escaping @Sendable () async -> Void) -> some View {
        #if os(macOS)
        refreshable(action: action)
        #else
        background(SystemRefreshControl(action: action))
        #endif
    }
}

#if os(iOS)
/// 把官方 `UIRefreshControl` 装到 SwiftUI `ScrollView` 底层的 `UIScrollView` 上。
///
/// 难点只有一个：**怎么可靠地拿到那个 `UIScrollView`**。
/// SwiftUI 把 `.background` 放成 ScrollView 的兄弟节点，父链上走不到它，
/// 所以这里用两步定位：
/// 1. 先沿父链找（万一锚点就在 ScrollView 内部）；
/// 2. 否则从窗口根往下找**包含锚点中心、且面积最小**的 `UIScrollView`。
///    `.background` 会被撑成 ScrollView 的大小，所以面积最小者就是它本身。
private struct SystemRefreshControl: UIViewRepresentable {
    var action: @Sendable () async -> Void

    func makeCoordinator() -> Coordinator {
        let work = action
        return Coordinator(action: { await work() })
    }

    func makeUIView(context: Context) -> AnchorView {
        let anchor = AnchorView(coordinator: context.coordinator)
        // 布局可能还没完成，第一次找不到就稍后重试几次
        anchor.scheduleAttachmentAttempts()
        return anchor
    }

    func updateUIView(_ anchor: AnchorView, context: Context) {
        let work = action
        context.coordinator.action = { await work() }
        anchor.attachIfNeeded()
    }

    final class AnchorView: UIView {
        let coordinator: Coordinator
        private weak var attachedTo: UIScrollView?
        private var attempts = 0

        init(coordinator: Coordinator) {
            self.coordinator = coordinator
            super.init(frame: .zero)
            isHidden = true
            isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            attachIfNeeded()
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            attachIfNeeded()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            attachIfNeeded()
        }

        func scheduleAttachmentAttempts() {
            for delay in [0.05, 0.2, 0.5, 1.0] {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.attachIfNeeded()
                }
            }
        }

        func attachIfNeeded() {
            guard attachedTo == nil, attempts < 40 else { return }
            attempts += 1
            guard let scrollView = locateScrollView() else { return }
            let control = UIRefreshControl()
            control.addTarget(coordinator, action: #selector(Coordinator.handle(_:)), for: .valueChanged)
            scrollView.refreshControl = control
            scrollView.alwaysBounceVertical = true
            coordinator.control = control
            attachedTo = scrollView
        }

        private func locateScrollView() -> UIScrollView? {
            // 1) 父链
            var node: UIView? = superview
            while let current = node {
                if let scrollView = current as? UIScrollView { return scrollView }
                node = current.superview
            }
            // 2) 从窗口根找「包含锚点中心且面积最小」的 UIScrollView
            guard let window else { return nil }
            let center = convert(CGPoint(x: bounds.midX, y: bounds.midY), to: window)
            var best: (view: UIScrollView, area: CGFloat)?
            func walk(_ view: UIView) {
                if let scrollView = view as? UIScrollView {
                    let frameInWindow = scrollView.convert(scrollView.bounds, to: window)
                    if frameInWindow.contains(center) {
                        let area = frameInWindow.width * frameInWindow.height
                        if best == nil || area < best!.area {
                            best = (scrollView, area)
                        }
                    }
                }
                view.subviews.forEach(walk)
            }
            walk(window)
            return best?.view
        }
    }

    final class Coordinator: NSObject {
        var action: @Sendable () async -> Void
        weak var control: UIRefreshControl?

        init(action: @escaping @Sendable () async -> Void) { self.action = action }

        @objc func handle(_ sender: UIRefreshControl) {
            Task { @MainActor in
                await action()
                sender.endRefreshing()
            }
        }
    }
}
#endif
