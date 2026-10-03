#!/usr/bin/env bash
# 把上游的非冲突更新合进当前分支，然后跑去推荐化锚点守卫。
set -uo pipefail
cd "$(dirname "$0")/.."
branch=$(git rev-parse --abbrev-ref HEAD)
if [ -n "$(git status --porcelain)" ]; then echo "工作区不干净：先提交或 stash"; exit 1; fi
echo "==> fetch upstream/main"
git fetch --quiet upstream main || { echo "fetch 失败：检查 upstream remote 与网络"; exit 1; }
before=$(git rev-parse --short HEAD)
if ! git merge --no-edit upstream/main; then
  echo "==> 合并有冲突：按 FORK.md「冲突兜底」处理后重跑本脚本"; exit 2
fi
echo "==> 合并完成（$branch）：$before -> $(git rev-parse --short HEAD)"
exec ./scripts/fork_check.sh
