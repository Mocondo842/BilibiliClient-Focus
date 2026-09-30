import Foundation

/// B 站视频下载引擎。
///
/// 这一块是自成一体的：输入一个 `DownloadRequest`，输出一个 `DownloadResult`，
/// 中间的分块传输、重试退避、限速、备用 CDN 轮换、音视频合流都在内部完成。
/// 它不依赖播放器，也不依赖任何界面代码，可以整块拿走单独使用。
///
/// 使用方式：
/// ```swift
/// let engine = BiliDownloadEngine()
/// let qualities = try await engine.qualities(for: request)
/// let result = try await engine.download(request, qualityID: qualities.first?.id) { progress in
///     Task { @MainActor in self.progress = progress }
/// }
/// ```
///
/// - Note: `progress` 回调发生在后台线程，界面侧需要自己切回主线程。
struct BiliDownloadEngine: Sendable {

    /// 无状态的共享实例。
    static let shared = BiliDownloadEngine()

    private let planner = DownloadPlanner()

    init() {}

    // MARK: - 清晰度

    /// 列出当前账号在这个视频上「实际下得动」的清晰度，按 qn 从高到低。
    ///
    /// 注意这不是服务器支持的全部清晰度：没有登录就只能看到 480P 及以下，
    /// 没有大会员就拿不到 1080P 高码率以上。
    func qualities(for request: DownloadRequest,
                   options: DownloadOptions = DownloadOptions()) async throws -> [DownloadQuality] {
        let plan = try await planner.plan(for: request, options: options.normalized())
        return plan.qualities
    }

    // MARK: - 下载

    /// 执行一次下载。
    ///
    /// - Parameters:
    ///   - request: 要下载的分P。
    ///   - qualityID: 目标清晰度 qn；nil 表示用 `options.quality` 里的偏好。
    ///   - options: 全部可调项。
    ///   - credentials: CDN 请求凭据，默认取应用当前登录态。
    ///   - progress: 进度回调（后台线程）。
    /// - Returns: 产物描述。
    @discardableResult
    func download(_ request: DownloadRequest,
                  qualityID: Int? = nil,
                  options: DownloadOptions = DownloadOptions(),
                  credentials: DownloadCredentials = .current,
                  progress: @Sendable @escaping (DownloadProgress) -> Void) async throws -> DownloadResult {

        let started = Date()
        var options = options.normalized()
        if let qualityID {
            options.quality = .exactly(qualityID)
        }

        progress(DownloadProgress(phase: .preparing,
                                  fileName: request.displayName,
                                  detail: "正在解析清晰度…"))

        let plan = try await planner.plan(for: request, options: options)
        let qualityName = plan.qualities.first { $0.id == plan.video.id }?.name ?? "qn \(plan.video.id)"

        let outputDirectory = options.resolvedOutputDirectory()
        let baseName = DownloadFileNaming.render(
            template: options.fileNameTemplate,
            request: request,
            quality: plan.qualities.first { $0.id == plan.video.id }
        )

        let workDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("bili-download-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: workDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: workDirectory) }

        let transport = ByteRangeTransport(credentials: credentials, options: options)

        // 1) 探测两条流的体积
        progress(DownloadProgress(phase: .preparing,
                                  fileName: baseName,
                                  detail: "正在探测资源体积…"))

        let videoInfo = try await transport.probe(plan.video.urls)
        guard let videoSize = videoInfo.totalSize, videoSize > 0 else {
            throw DownloadError.unknownResourceSize
        }

        var audioSize: Int64 = 0
        var audioInfo: ByteRangeTransport.ResourceInfo?
        if let audio = plan.audio, options.muxAudio {
            audioInfo = try? await transport.probe(audio.urls)
            audioSize = audioInfo?.totalSize ?? 0
        }

        let totalBytes = videoSize + audioSize
        try Self.ensureSpace(at: workDirectory,
                             required: options.container == .mp4 ? totalBytes * 2 : totalBytes)
        try Self.ensureSpace(at: outputDirectory, required: totalBytes)

        // 2) 下载视频轨
        let reporter = DownloadProgressReporter(
            fileName: baseName,
            total: totalBytes,
            emit: progress
        )
        reporter.setPhase(.downloading, detail: plan.audio != nil ? "下载视频轨" : "下载视频流")

        // 中间文件刻意用 .mp4 而不是 .m4s：AVFoundation 靠扩展名判断媒体类型，
        // .m4s 它认不出来，合流时会直接报「不支持此媒体的格式」。
        let videoURL = workDirectory.appendingPathComponent("video.mp4")
        if videoInfo.supportsRanges {
            try await transport.download(urls: plan.video.urls,
                                         to: videoURL,
                                         totalSize: videoSize) { received in
                reporter.update(overallBytes: received)
            }
        } else {
            try await transport.downloadSequentially(urls: plan.video.urls, to: videoURL)
            reporter.update(overallBytes: videoSize)
        }

        // 3) 下载音频轨
        var audioURL: URL?
        if let audio = plan.audio, options.muxAudio {
            reporter.setPhase(.downloading, detail: "下载音频轨")
            let destination = workDirectory.appendingPathComponent("audio.mp4")
            if let audioInfo, let size = audioInfo.totalSize, size > 0, audioInfo.supportsRanges {
                try await transport.download(urls: audio.urls,
                                             to: destination,
                                             totalSize: size) { received in
                    reporter.update(overallBytes: videoSize + received)
                }
            } else {
                try await transport.downloadSequentially(urls: audio.urls, to: destination)
                reporter.update(overallBytes: videoSize + max(audioSize, 0))
            }
            audioURL = destination
        }

        // 4) 落盘
        let result: DownloadResult
        switch options.container {
        case .mp4:
            reporter.setPhase(.muxing, detail: "正在合流音视频…")
            let staged = workDirectory.appendingPathComponent("\(baseName).mp4")
            try await DownloadMuxer.mux(video: videoURL,
                                        audio: audioURL,
                                        to: staged,
                                        options: options)

            let finalURL = DownloadFileNaming.uniqueURL(in: outputDirectory,
                                                        baseName: baseName,
                                                        pathExtension: "mp4",
                                                        overwrite: options.overwriteExisting)
            try Self.move(from: staged, to: finalURL)

            // 关掉 deleteIntermediateFiles 时，把两条原始轨也留在产物旁边，
            // 方便事后自己重封装或单独取轨。
            var extra: [URL] = []
            if !options.deleteIntermediateFiles {
                extra.append(try Self.moveAside(from: videoURL,
                                                to: outputDirectory,
                                                baseName: baseName + ".video",
                                                overwrite: options.overwriteExisting))
                if let audioURL {
                    extra.append(try Self.moveAside(from: audioURL,
                                                    to: outputDirectory,
                                                    baseName: baseName + ".audio",
                                                    overwrite: options.overwriteExisting))
                }
            }

            let size = Self.fileSize(finalURL) + extra.reduce(Int64(0)) { $0 + Self.fileSize($1) }
            reporter.setPhase(.finished, detail: "已保存到 \(finalURL.lastPathComponent)")
            result = DownloadResult(fileURL: finalURL,
                                    additionalFiles: extra,
                                    qualityName: qualityName,
                                    byteCount: size,
                                    elapsed: Date().timeIntervalSince(started))

        case .rawStreams:
            let videoDestination = try Self.moveAside(from: videoURL,
                                                      to: outputDirectory,
                                                      baseName: baseName + ".video",
                                                      overwrite: options.overwriteExisting)

            var extra: [URL] = []
            if let audioURL {
                extra.append(try Self.moveAside(from: audioURL,
                                                to: outputDirectory,
                                                baseName: baseName + ".audio",
                                                overwrite: options.overwriteExisting))
            }

            let size = Self.fileSize(videoDestination) + extra.reduce(Int64(0)) { $0 + Self.fileSize($1) }
            reporter.setPhase(.finished, detail: "已保存 \(1 + extra.count) 个文件")
            result = DownloadResult(fileURL: videoDestination,
                                    additionalFiles: extra,
                                    qualityName: qualityName,
                                    byteCount: size,
                                    elapsed: Date().timeIntervalSince(started))
        }

        AppLog.player.info("下载完成 bvid=\(request.bvid) cid=\(request.cid) qn=\(plan.video.id) 体积=\(result.byteCount)B 耗时=\(String(format: "%.1f", result.elapsed))s")
        return result
    }

    // MARK: - 辅助

    /// 剩余空间不足就提前报错，别等下了 90% 才写失败。
    private static func ensureSpace(at directory: URL, required: Int64) throws {
        guard required > 0 else { return }
        let values = try? directory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        guard let available = values?.volumeAvailableCapacityForImportantUsage, available > 0 else {
            return
        }
        guard available >= required else {
            throw DownloadError.insufficientSpace(required: required, available: available)
        }
    }

    private static func fileSize(_ url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey])
        return Int64(values?.fileSize ?? 0)
    }

    /// 先试移动，跨卷时退回「拷贝 + 删除」，避免因为临时目录与下载目录不同卷而失败。
    private static func move(from source: URL, to destination: URL) throws {
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destination)
        do {
            try fileManager.moveItem(at: source, to: destination)
        } catch {
            try fileManager.copyItem(at: source, to: destination)
            try? fileManager.removeItem(at: source)
        }
    }

    /// 把一个中间轨文件挪到输出目录并返回最终落点。
    private static func moveAside(from source: URL,
                                  to directory: URL,
                                  baseName: String,
                                  overwrite: Bool) throws -> URL {
        let destination = DownloadFileNaming.uniqueURL(in: directory,
                                                       baseName: baseName,
                                                       pathExtension: "m4s",
                                                       overwrite: overwrite)
        try move(from: source, to: destination)
        return destination
    }
}

// MARK: - 进度聚合

/// 把「某个阶段的累计字节」翻译成界面要的进度：总比例、实时速度、预计剩余。
///
/// 多线程写入（每个分块 worker 都会调 `update`），所以内部加锁；
/// 速度用两次采样之间的差值算，避免累计平均把瞬时抖动抹平。
private final class DownloadProgressReporter: @unchecked Sendable {
    private let lock = NSLock()
    private let emit: @Sendable (DownloadProgress) -> Void
    private let fileName: String

    private var phase: DownloadProgress.Phase = .preparing
    private var detail: String?
    private var total: Int64
    private var received: Int64 = 0
    private var startedAt = Date()
    private var lastSampleAt = Date()
    private var lastSampleBytes: Int64 = 0
    private var speed: Double = 0
    private var lastEmitAt = Date.distantPast

    init(fileName: String, total: Int64, emit: @escaping @Sendable (DownloadProgress) -> Void) {
        self.fileName = fileName
        self.total = total
        self.emit = emit
    }

    func setPhase(_ phase: DownloadProgress.Phase, detail: String?) {
        lock.lock()
        self.phase = phase
        self.detail = detail
        lock.unlock()
        publish(force: true)
    }

    /// `overallBytes` 是「整个下载任务」的累计字节，跨阶段连续。
    func update(overallBytes: Int64) {
        lock.lock()
        received = max(overallBytes, received)
        let now = Date()
        let elapsed = now.timeIntervalSince(lastSampleAt)
        if elapsed >= 0.5 {
            let delta = Double(received - lastSampleBytes)
            let instant = delta / elapsed
            // 指数滑动平均，避免速度数字乱跳
            speed = speed == 0 ? instant : speed * 0.6 + instant * 0.4
            lastSampleAt = now
            lastSampleBytes = received
        }
        lock.unlock()
        publish(force: false)
    }

    private func publish(force: Bool) {
        lock.lock()
        let now = Date()
        guard force || now.timeIntervalSince(lastEmitAt) >= 0.2 else {
            lock.unlock()
            return
        }
        lastEmitAt = now

        let snapshotTotal = total
        let snapshotReceived = received
        let snapshotSpeed = speed
        let snapshotPhase = phase
        let snapshotDetail = detail
        let elapsed = now.timeIntervalSince(startedAt)
        lock.unlock()

        var fraction: Double?
        var remaining: TimeInterval?
        if snapshotTotal > 0 {
            let value = min(max(Double(snapshotReceived) / Double(snapshotTotal), 0), 1)
            fraction = value
            if snapshotSpeed > 0, value < 1 {
                remaining = Double(snapshotTotal - snapshotReceived) / snapshotSpeed
            }
        }
        // 还没采到速度时退回整体平均，至少给个粗略估计
        if remaining == nil, snapshotSpeed == 0, elapsed > 1, snapshotReceived > 0, snapshotTotal > snapshotReceived {
            let average = Double(snapshotReceived) / elapsed
            if average > 0 { remaining = Double(snapshotTotal - snapshotReceived) / average }
        }

        emit(DownloadProgress(phase: snapshotPhase,
                              bytesReceived: snapshotReceived,
                              bytesTotal: snapshotTotal,
                              fraction: fraction,
                              bytesPerSecond: snapshotSpeed,
                              estimatedRemaining: remaining,
                              fileName: fileName,
                              detail: snapshotDetail))
    }
}
