import AVFoundation
import Foundation

/// 把下载好的视频轨与音频轨合成单个 MP4。
///
/// 刻意不引入 ffmpeg：B 站下下来的 m4s 本身就是标准 fragmented MP4，
/// 系统的 `AVMutableComposition` + `AVAssetExportSession` 足以重组轨道。
/// 默认走 passthrough（不重编码），因此合流几乎是瞬时的、也不损失画质。
enum DownloadMuxer {

    /// 合流。
    ///
    /// - Parameters:
    ///   - video: 视频轨 m4s。
    ///   - audio: 音频轨 m4s，nil 表示只输出视频。
    ///   - options: 用 `preferPassthrough` 决定是否优先无损合流。
    /// - Returns: 输出文件路径。
    @discardableResult
    static func mux(video: URL,
                    audio: URL?,
                    to output: URL,
                    options: DownloadOptions) async throws -> URL {
        let composition = AVMutableComposition()
        let videoAsset = AVURLAsset(url: video)

        guard let sourceVideo = try await videoAsset.loadTracks(withMediaType: .video).first else {
            throw DownloadError.muxFailed("下载到的文件里没有视频轨")
        }

        let videoDuration = try await videoAsset.load(.duration)
        guard videoDuration.isValid, videoDuration.seconds > 0 else {
            throw DownloadError.muxFailed("视频轨时长无效，文件可能不完整")
        }

        guard let compositionVideo = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw DownloadError.muxFailed("无法创建输出视频轨")
        }
        try compositionVideo.insertTimeRange(
            CMTimeRange(start: .zero, duration: videoDuration),
            of: sourceVideo,
            at: .zero
        )
        // 保留旋转信息，否则竖屏视频会被摆正
        compositionVideo.preferredTransform = try await sourceVideo.load(.preferredTransform)

        if let audio {
            let audioAsset = AVURLAsset(url: audio)
            if let sourceAudio = try await audioAsset.loadTracks(withMediaType: .audio).first,
               let compositionAudio = composition.addMutableTrack(
                   withMediaType: .audio,
                   preferredTrackID: kCMPersistentTrackID_Invalid
               ) {
                let audioDuration = try await audioAsset.load(.duration)
                // 音视频时长常常差几帧，取短的，免得导出时尾部报错
                let duration = CMTimeMinimum(videoDuration, audioDuration)
                try compositionAudio.insertTimeRange(
                    CMTimeRange(start: .zero, duration: duration),
                    of: sourceAudio,
                    at: .zero
                )
            }
        }

        let presets: [String] = options.preferPassthrough
            ? [AVAssetExportPresetPassthrough, AVAssetExportPresetHighestQuality]
            : [AVAssetExportPresetHighestQuality]

        var lastError: Error?
        for preset in presets {
            try? FileManager.default.removeItem(at: output)
            guard let export = AVAssetExportSession(asset: composition, presetName: preset) else {
                continue
            }
            do {
                try await export.export(to: output, as: .mp4)
                return output
            } catch {
                lastError = error
            }
        }

        throw DownloadError.muxFailed(lastError?.localizedDescription ?? "没有可用的导出预设")
    }
}
