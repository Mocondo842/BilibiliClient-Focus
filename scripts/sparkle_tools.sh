#!/bin/bash
# 确保 Sparkle 的命令行工具（generate_appcast / sign_update / generate_keys）可用。
# 工具来自 Sparkle 官方 Release 包，缓存在 .build/sparkle-tools/，不写系统目录。
set -euo pipefail

SPARKLE_VERSION="${SPARKLE_VERSION:-2.10.0}"
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd)/.build/sparkle-tools"
BIN_DIR="$TOOLS_DIR/bin"

if [ ! -x "$BIN_DIR/generate_appcast" ]; then
  mkdir -p "$TOOLS_DIR"
  echo "下载 Sparkle $SPARKLE_VERSION 工具…" >&2
  curl -sL --max-time 300 \
    -o "$TOOLS_DIR/sparkle.tar.xz" \
    "https://github.com/sparkle-project/Sparkle/releases/download/${SPARKLE_VERSION}/Sparkle-${SPARKLE_VERSION}.tar.xz"
  tar xf "$TOOLS_DIR/sparkle.tar.xz" -C "$TOOLS_DIR" bin
fi

echo "$BIN_DIR"
