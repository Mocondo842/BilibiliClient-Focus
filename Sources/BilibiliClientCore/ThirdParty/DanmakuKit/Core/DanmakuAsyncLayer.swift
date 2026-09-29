//
//  DanmakuAsyncLayer.swift
//  DanmakuKit
//
//  Created by Q YiZhong on 2020/8/16.
//

#if canImport(UIKit)
import UIKit
#else
#if os(macOS)
import AppKit
#else
import UIKit
#endif
#endif

class Sentinel {
    
    private var value: Int32 = 0
    
    public func getValue() -> Int32 {
        return value
    }
    
    public func increase() {
        #if os(macOS)
        _ = OSAtomicIncrement32(&value)
        #else
        let p = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        p.pointee = value
        OSAtomicIncrement32(p)
        p.deallocate()
        #endif
    }
    
}

public class DanmakuAsyncLayer: CALayer {
    
    /// When true, it is drawn asynchronously and is ture by default.
    public var displayAsync = true
    
    public var willDisplay: ((_ layer: DanmakuAsyncLayer) -> Void)?
    
    public var displaying: ((_ context: CGContext, _ size: CGSize, _ isCancelled:(() -> Bool)) -> Void)?
    
    public var didDisplay: ((_ layer: DanmakuAsyncLayer, _ finished: Bool) -> Void)?
    
    /// The number of queues to draw the danmaku.
    public static var drawDanmakuQueueCount = 16 {
        didSet {
            guard drawDanmakuQueueCount != oldValue else { return }
            pool = nil
            createPoolIfNeed()
        }
    }
    
    private let sentinel = Sentinel()
    
    private static var pool: DanmakuQueuePool?
    
    override init() {
        super.init()
        contentsScale = PlatformScreen.mainScale(fallback: 1)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        sentinel.increase()
    }
    
    public override func setNeedsDisplay() {
        //1. Cancel the last drawing
        sentinel.increase()
        //2. call super
        super.setNeedsDisplay()
    }
    
    public override func display() {
        display(isAsync: displayAsync)
    }
    
    private func display(isAsync: Bool) {
        guard displaying != nil, bounds.size.width > 0, bounds.size.height > 0 else {
            willDisplay?(self)
            contents = nil
            didDisplay?(self, true)
            return
        }
        
        if isAsync {
            willDisplay?(self)
            let value = sentinel.getValue()
            let isCancelled = {() -> Bool in
                return value != self.sentinel.getValue()
            }
            let size = bounds.size
            let scale = contentsScale
            let opaque = isOpaque
            let backgroundColor = (opaque && self.backgroundColor != nil) ? self.backgroundColor : nil
            queue.async {
                guard !isCancelled() else { return }
                #if os(macOS)
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let alphaInfo: CGImageAlphaInfo = opaque ? .noneSkipLast : .premultipliedLast
                guard let context = CGContext(data: nil, width: Int(size.width * scale), height: Int(size.height * scale), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: alphaInfo.rawValue) else {
                    return
                }
                context.scaleBy(x: scale, y: scale)
                if opaque {
                    context.saveGState()
                    if backgroundColor == nil || (backgroundColor?.alpha ?? 0) < 1 {
                        context.setFillColor(NSColor.white.cgColor)
                        context.fill(CGRect(origin: .zero, size: size))
                    }
                    if let bg = backgroundColor {
                        context.setFillColor(bg)
                        context.fill(CGRect(origin: .zero, size: size))
                    }
                    context.restoreGState()
                }
                #else
                UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
                guard let context = UIGraphicsGetCurrentContext() else {
                    UIGraphicsEndImageContext()
                    return
                }
                if opaque {
                    context.saveGState()
                    if backgroundColor == nil || (backgroundColor?.alpha ?? 0) < 1 {
                        context.setFillColor(UIColor.white.cgColor)
                        // `UIGraphicsBeginImageContextWithOptions` 交出的上下文坐标已经是**点**（scale 已折算进 CTM），
                        // 这里不能再乘 `scale`，否则白底矩形会是位图的 scale² 倍、整格铺满。
                        // 与上面 macOS 分支的 `CGRect(origin: .zero, size: size)` 保持一致。
                        context.addRect(CGRect(origin: .zero, size: size))
                        context.fillPath()
                    }
                    if let backgroundColor = backgroundColor {
                        context.setFillColor(backgroundColor)
                        // `UIGraphicsBeginImageContextWithOptions` 交出的上下文坐标已经是**点**（scale 已折算进 CTM），
                        // 这里不能再乘 `scale`，否则白底矩形会是位图的 scale² 倍、整格铺满。
                        // 与上面 macOS 分支的 `CGRect(origin: .zero, size: size)` 保持一致。
                        context.addRect(CGRect(origin: .zero, size: size))
                        context.fillPath()
                    }
                    context.restoreGState()
                }
                #endif
                #if os(macOS)
                self.displaying?(context, size, isCancelled)
                #else
                // Core Text 按 **Y 向上** 绘制，而 `UIGraphicsBeginImageContextWithOptions`
                // 交出的上下文是 **Y 向下**（UIKit 约定）。不翻转，弹幕文字会被上下镜像
                // ——这正是 iOS 上「弹幕颠倒」的原因。翻成 Y 向上后与 macOS 分支逐像素一致。
                context.translateBy(x: 0, y: size.height)
                context.scaleBy(x: 1, y: -1)
                self.displaying?(context, size, isCancelled)
                #endif
                if isCancelled() {
                    #if os(macOS)
                    // no UIGraphics context to end on macOS
                    #else
                    UIGraphicsEndImageContext()
                    #endif
                    DispatchQueue.main.async {
                        self.didDisplay?(self, false)
                    }
                    return
                }
                #if os(macOS)
                let cgImage = context.makeImage()
                if isCancelled() {
                    DispatchQueue.main.async { self.didDisplay?(self, false) }
                    return
                }
                DispatchQueue.main.async {
                    if isCancelled() { self.didDisplay?(self, false) }
                    else { self.contents = cgImage; self.didDisplay?(self, true) }
                }
                #else
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                if isCancelled() {
                    DispatchQueue.main.async {
                        self.didDisplay?(self, false)
                    }
                    return
                }
                DispatchQueue.main.async {
                    if isCancelled() {
                        self.didDisplay?(self, false)
                    } else {
                        self.contents = image?.cgImage
                        self.didDisplay?(self, true)
                    }
                }
                #endif
            }
            
        } else {
            sentinel.increase()
            willDisplay?(self)
            #if os(macOS)
            let size = bounds.size
            let scale = contentsScale
            let opaque = isOpaque
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let alphaInfo: CGImageAlphaInfo = opaque ? .noneSkipLast : .premultipliedLast
            guard let context = CGContext(data: nil,
                                          width: Int(size.width * scale),
                                          height: Int(size.height * scale),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 0,
                                          space: colorSpace,
                                          bitmapInfo: alphaInfo.rawValue) else {
                return
            }
            context.scaleBy(x: scale, y: scale)
            if opaque {
                context.saveGState()
                if self.backgroundColor == nil || (self.backgroundColor?.alpha ?? 0) < 1 {
                    context.setFillColor(NSColor.white.cgColor)
                    context.fill(CGRect(origin: .zero, size: size))
                }
                if let bg = self.backgroundColor {
                    context.setFillColor(bg)
                    context.fill(CGRect(origin: .zero, size: size))
                }
                context.restoreGState()
            }
            displaying?(context, bounds.size, {() -> Bool in return false})
            let image = context.makeImage()
            contents = image
            didDisplay?(self, true)
            #else
            UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, contentsScale)
            guard let context = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndImageContext()
                return
            }
            // 同上：翻成 Y 向上，Core Text 才画得正。
            context.translateBy(x: 0, y: bounds.size.height)
            context.scaleBy(x: 1, y: -1)
            displaying?(context, bounds.size, {() -> Bool in return false})
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            contents = image?.cgImage
            didDisplay?(self, true)
            #endif
        }
    }
    
    private static func createPoolIfNeed() {
        guard DanmakuAsyncLayer.pool == nil else { return }
        DanmakuAsyncLayer.pool = DanmakuQueuePool(name: "com.DanmakuKit.DanmakuAsynclayer", queueCount: DanmakuAsyncLayer.drawDanmakuQueueCount, qos: .userInteractive)
    }
    
    private lazy var queue: DispatchQueue = {
        return DanmakuAsyncLayer.pool?.queue ?? DispatchQueue(label: "com.DanmakuKit.DanmakuAsynclayer")
    }()
    
}
