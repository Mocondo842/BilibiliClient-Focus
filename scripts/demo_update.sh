#!/bin/bash
# 本地端到端演示自动更新：造一个"已安装的旧版 1.7.3"和一个"新发布的 1.7.4"，
# 用本机 http 服务当更新源，启动旧版后点「检查更新…」就能看到完整流程。
#
#   ./scripts/demo_update.sh          # 起服务 + 启动旧版
#   ./scripts/demo_update.sh --build  # 只准备产物，不起服务
set -euo pipefail
cd "$(dirname "$0")/.."

OLD_VERSION=1.7.3
NEW_VERSION=1.7.4
PORT="${DEMO_PORT:-8123}"
FEED_URL="http://127.0.0.1:${PORT}/appcast.xml"
DEMO_DIR="dist/update-demo"
BIN_DIR="$("./scripts/sparkle_tools.sh")"

mkdir -p "$DEMO_DIR/feed" "$DEMO_DIR/installed"

echo "==> 1/3 构建新版 ${NEW_VERSION}（作为更新源）"
printf '%s' "$NEW_VERSION" > version.txt
BUILD=100000 NO_OPEN=1 SPARKLE_FEED_URL="$FEED_URL" ./scripts/build_app.sh release >/dev/null
ditto -c -k --sequesterRsrc --keepParent "dist/BilibiliClient.app" \
  "$DEMO_DIR/feed/BilibiliClient-${NEW_VERSION}.zip"
"$BIN_DIR/generate_appcast" "$DEMO_DIR/feed" >/dev/null
echo "    appcast: $DEMO_DIR/feed/appcast.xml"

echo "==> 2/3 构建旧版 ${OLD_VERSION}（作为已安装版本，指向本地 feed）"
printf '%s' "$OLD_VERSION" > version.txt
BUILD=99999 NO_OPEN=1 SPARKLE_FEED_URL="$FEED_URL" ./scripts/build_app.sh release >/dev/null
rm -rf "$DEMO_DIR/installed/BilibiliClient.app"
ditto "dist/BilibiliClient.app" "$DEMO_DIR/installed/BilibiliClient.app"

echo "==> 3/3 还原仓库版本号并重建正式产物"
printf '%s' "$(git show HEAD:version.txt | tr -d '\n')" > version.txt
NO_OPEN=1 ./scripts/build_app.sh release >/dev/null

if [ "${1:-}" = "--build" ]; then
  echo "演示产物已就绪：$DEMO_DIR"
  exit 0
fi

echo
echo "更新源： $FEED_URL"
echo "旧版 App：$DEMO_DIR/installed/BilibiliClient.app（版本 ${OLD_VERSION}）"
echo "新版包： $DEMO_DIR/feed/BilibiliClient-${NEW_VERSION}.zip（版本 ${NEW_VERSION}）"
echo
echo "接下来：保持这个终端窗口开着，然后在启动的 App 里点"
echo "  菜单栏「Bilibili Client → 检查更新…」或「设置 → 关于 → 检查更新…」"
echo "Sparkle 会发现 ${NEW_VERSION}、下载、校验签名、替换并重启。按 Control-C 结束。"
echo

( cd "$DEMO_DIR/feed" && python3 -m http.server "$PORT" --bind 127.0.0.1 ) &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null || true' EXIT
sleep 1
open "$DEMO_DIR/installed/BilibiliClient.app"
wait "$SERVER_PID"
