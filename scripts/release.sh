#!/bin/bash
# 打包一个可被 Sparkle 自动更新的版本。
#
#   ./scripts/release.sh 1.7.3            # 只生成本地发布物（dist/release/）
#   ./scripts/release.sh 1.7.3 --publish  # 同时用 gh 上传 GitHub Release 并更新 docs/appcast.xml
#
# 产物：
#   dist/release/BilibiliClient-<version>.zip   替换用更新包（appcast 指向它）
#   dist/release/appcast.xml                    更新源（EdDSA 签名，放到 docs/ 后即可作为 SUFeedURL）
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"
PUBLISH="${2:-}"
if [ -z "$VERSION" ]; then
  echo "用法: ./scripts/release.sh <version> [--publish]" >&2
  exit 1
fi

BIN_DIR="$("./scripts/sparkle_tools.sh")"
RELEASE_DIR="dist/release"
ZIP_NAME="BilibiliClient-${VERSION}.zip"

echo "==> 构建 $VERSION"
printf '%s' "$VERSION" > version.txt
NO_OPEN=1 ./scripts/build_app.sh release

echo "==> 打包 zip"
mkdir -p "$RELEASE_DIR"
ditto -c -k --sequesterRsrc --keepParent "dist/BilibiliClient.app" "$RELEASE_DIR/$ZIP_NAME"

echo "==> 生成 / 更新 appcast（EdDSA 签名）"
# 发布说明可选：同名的 .md 会被 generate_appcast 收进 feed
# 下载地址前缀指向 GitHub Release 的资产目录，appcast 里的 enclosure 才是绝对地址
"$BIN_DIR/generate_appcast" "$RELEASE_DIR" \
  --download-url-prefix "https://github.com/Mora-han/BilibiliClient/releases/download/v${VERSION}/"

echo "==> 本地发布物："
ls -lh "$RELEASE_DIR"/appcast.xml "$RELEASE_DIR/$ZIP_NAME"

if [ "$PUBLISH" = "--publish" ]; then
  echo "==> 上传 GitHub Release v$VERSION"
  if ! command -v gh >/dev/null; then
    echo "未安装 gh（brew install gh）；跳过上传，可手动把 zip 传到 Release。" >&2
  else
    gh release create "v$VERSION" "$RELEASE_DIR/$ZIP_NAME" \
      --title "v$VERSION" --notes "见 docs/appcast.xml"
  fi
  echo "==> 更新 docs/appcast.xml（本地 raw 地址即 SUFeedURL）"
  mkdir -p docs
  cp "$RELEASE_DIR/appcast.xml" docs/appcast.xml
  echo "别忘了：git add docs/appcast.xml && git commit && git push（feed 才能生效）"
fi

echo
echo "提示：App 的 SUFeedURL 默认指向"
echo "  https://raw.githubusercontent.com/Mora-han/BilibiliClient/main/docs/appcast.xml"
