import AVFoundation
import SwiftUI

/// 直播播放组件：系统 AVPlayerView（画面 + 原生全屏）+ 自绘液态玻璃控制栏 + 在线人数徽标。
/// 全屏（含全屏动画）由 AVKit 负责；控制栏是直播变体：没有时间轴（换成"直播"徽标），
/// 也没有弹幕开关与画质入口，只保留播放/倍速/音量/画中画/全屏。
struct LivePlayerSurface: View {
    @ObservedObject var model: LivePlayerModel

    var body: some View {
        ZStack {
            Color.black
            if let player = model.player {
                PlayerSurfaceView(player: player,
                                  engine: nil,
                                  danmakuEnabled: false,
                                  danmakuSettings: .current,
                                  controls: controls)
                    .id(player)
            } else if model.state == .loading {
                VStack(spacing: 10) {
                    ProgressView()
                    Text("正在连接直播间…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if model.state == .offline {
                VStack(spacing: 10) {
                    Image(systemName: "moon.zzz")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("主播还未开播").font(.headline)
                }
            } else if model.state == .failed {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("直播加载失败").font(.headline)
                    Text(model.errorMessage ?? "未知错误")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("重试") {
                        Task { await model.retryCurrent() }
                    }
                }
                .padding()
            }
        }
        .overlay(alignment: .topLeading) {
            // 在线人数
            if let text = model.onlineText {
                PlayerOnlineBadge(text: text)
                    .padding(10)
                    .allowsHitTesting(false)
            }
        }
        .clipped()
    }

    /// 自绘控制栏的直播变体输入：没有时间轴/弹幕/画质，只接播放开关
    private var controls: PlayerBarConfig {
        var config = PlayerBarConfig()
        config.isLive = true
        config.onTogglePlay = { model.togglePlay() }
        return config
    }
}
