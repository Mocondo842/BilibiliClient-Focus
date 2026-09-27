#if os(macOS)
import AppKit

/// 本地键盘事件监视器（F7/F8/F9 等按键在 App 前台时以普通 `NSEvent` 到达）。
///
/// 这里是 SwiftUIX `NSEventMonitor` 的等价精简实现：SwiftUIX 在 iOS SDK 下编译不过，
/// 而项目里只用到「本地监视 + 返回值决定是否吞掉事件」这一条路径，所以照抄它对
/// `NSEvent.addLocalMonitorForEvents` / `removeMonitor` 的封装即可，行为一致。
final class NSEventMonitor {
    enum Context {
        case local
        case global
    }

    private let context: Context
    private let eventTypeMask: NSEvent.EventTypeMask
    private var monitor: Any?

    /// 返回 `nil` 表示吞掉该事件，返回原事件表示继续传递。
    private let handleEvent: (NSEvent) -> NSEvent?

    /// init 即启动（与 SwiftUIX 一致）。
    init(context: Context,
         matching mask: NSEvent.EventTypeMask,
         handleEvent: @escaping (NSEvent) -> NSEvent?) {
        self.context = context
        self.eventTypeMask = mask
        self.handleEvent = handleEvent
        start()
    }

    func start() {
        guard monitor == nil else { return }
        switch context {
        case .local:
            monitor = NSEvent.addLocalMonitorForEvents(matching: eventTypeMask) { [weak self] event in
                guard let self else { return event }
                return self.handleEvent(event)
            }
        case .global:
            monitor = NSEvent.addGlobalMonitorForEvents(matching: eventTypeMask) { [weak self] event in
                _ = self?.handleEvent(event)
            }
        }
    }

    func stop() {
        guard let monitor else { return }
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }

    deinit {
        stop()
    }
}
#endif
