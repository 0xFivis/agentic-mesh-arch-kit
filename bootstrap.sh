#!/usr/bin/env bash
# agentic-mesh-arch-kit / bootstrap.sh
# ----------------------------------------------------------------------
# 远程一行式骨架入口 — 把 kit clone 到临时目录后调 scripts/scaffold.sh
#
# 用法（在 *空目录* 内执行；目录名建议与 --name 一致）：
#   mkdir my-platform && cd my-platform
#   bash <(curl -sSL https://raw.githubusercontent.com/0xFivis/agentic-mesh-arch-kit/main/bootstrap.sh) --name my-platform
#
# 环境变量：
#   KIT_REF      指定分支/Tag/Commit（默认 main）
#   KIT_REPO     覆盖仓库 URL（默认 https://github.com/0xFivis/agentic-mesh-arch-kit.git）
#   KEEP_TMP     设为 1 时保留临时 clone 目录
#
# 所有其它参数透传给 scripts/scaffold.sh：
#   --name <project-name>   （必填）
#   --with-examples  --dry-run  --target <dir>
# ----------------------------------------------------------------------

set -euo pipefail

KIT_REPO="${KIT_REPO:-https://github.com/0xFivis/agentic-mesh-arch-kit.git}"
KIT_REF="${KIT_REF:-main}"
KEEP_TMP="${KEEP_TMP:-0}"
ORIG_PWD="$PWD"

log()  { printf '\033[1;34m[bootstrap]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

command -v git >/dev/null  || { err "需要 git";  exit 127; }
command -v bash >/dev/null || { err "需要 bash"; exit 127; }

TMP="$(mktemp -d -t agentic-mesh-arch-kit.XXXXXX)"
cleanup() {
  if [[ "$KEEP_TMP" == "1" ]]; then
    log "保留临时目录: $TMP"
  else
    rm -rf "$TMP"
  fi
}
trap cleanup EXIT

log "仓库: $KIT_REPO"
log "Ref:  $KIT_REF"
log "临时目录: $TMP"

if ! git clone --depth=1 --branch "$KIT_REF" --quiet "$KIT_REPO" "$TMP" 2>/dev/null; then
  log "shallow clone 失败，回退到全量 clone 后 checkout $KIT_REF"
  rm -rf "$TMP"
  git clone --quiet "$KIT_REPO" "$TMP"
  ( cd "$TMP" && git checkout --quiet "$KIT_REF" )
fi

cd "$ORIG_PWD"
log "调用 $TMP/scripts/scaffold.sh"
exec bash "$TMP/scripts/scaffold.sh" --target "$ORIG_PWD" "$@"
