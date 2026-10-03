#!/usr/bin/env bash
# 去推荐化补丁锚点自检。每次同步上游之后运行；缺失任一锚点即退出 1。
#
# 设计要点：**不绑定文件路径**。上游可能把文件搬走（v1.7.3→v1.8.2 就发生过 Core 抽取），
# 因此这里在 Sources/ 全树里找锚点，只回答「补丁还在不在」。
# 本脚本是文本级检查，不是编译器：类型层是否仍然成立由构建负责。
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
ok()  { printf '  ok    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fail=1; }

need() {   # need <正则> <说明>
  if grep -rqE "$1" Sources --include=*.swift; then ok "$2"; else bad "$2（锚点缺失）"; fi
}
forbid() { # forbid <正则> <说明>
  if grep -rqE "$1" Sources --include=*.swift; then bad "$2（推流面又出现）"; else ok "$2"; fi
}

echo "[1/4] 补丁文件"
if [ -n "$(find Sources -name DeRecommendation.swift -print -quit)" ]; then ok "DeRecommendation.swift 存在"; else bad "DeRecommendation.swift 缺失"; fi
need 'static let browseItems: \[RootView\.SidebarItem\] = \[\.dynamics\]' 'browseItems 只留动态'
need 'DYNAMIC_TYPE_LIVE_RCMD' '官方注入类型黑名单仍在'
need 'blockedMajorTypes' 'MAJOR_TYPE_LIVE_RCMD 兜底仍在'
need 'moduleDynamic != nil \|\| item\.orig != nil' '空条目兜底判定仍在'
echo "[2/4] 导航"
need 'selection: SidebarItem\? = \.dynamics' '默认落地页 = 动态'
need 'ForEach\(DeRecommendation\.browseItems\)' '侧边栏/标签栏用补丁清单'
if grep -rA1 'case nil:' Sources --include=*.swift | grep -q 'DynamicFeedView()'; then ok "空选中回落到动态"; else bad "空选中回落（应为 DynamicFeedView）"; fi
forbid 'Tab\("(推荐|分区|热门|直播)"' 'iOS 标签栏不含推荐/分区/热门/直播'
echo "[3/4] 过滤"
need 'items\.followOnly' '去推荐化：动态流过滤仍在'
need 'videoOnly' '仅视频筛选仍在'
need 'PlaybackProgressStore' '本地播放进度仍在'
need 'restorePendingResumeWhenReady' '就绪后恢复进度（切清晰度不丢位置）仍在'
need 'AVPlayerItemDidPlayToEndTime' '播完清进度仍在'
need 'SessionFallbackStore' '登录兜底存储仍在'
need 'PlaybackPreferences\.initialQuality' '优先清晰度仍在'
need 'PlaybackPreferences\.preferredStreams' '优先编码仍在'
need 'CommentFonts\.' '评论字号缩放仍在'
need 'ForEach\(items\.followOnly\)' '菜单栏面板过滤'
echo
echo "[4/4] 自动更新"
if grep -qE 'SPARKLE_FEED_URL:-https://example\.invalid/bilibiliclient-fork/appcast\.xml' scripts/build_app.sh; then
  ok "Sparkle 默认 feed 不指向上游"
else
  bad "Sparkle 默认 feed 仍可能指向上游（会把补丁版覆盖回官方版）"
fi
echo
if [ "$fail" = 0 ]; then echo "结果：全部锚点在位（补丁完整）"; else echo "结果：有锚点缺失——同步上游后需要重放补丁，做法见 FORK.md"; fi
exit $fail
