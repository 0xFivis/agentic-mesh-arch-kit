#!/usr/bin/env bash
# agentic-mesh-arch-kit / scripts/new-service.sh
# 用法：bash scripts/new-service.sh --type <api|worker|saga> --name <short-name> --bctx <bctx-id> [--preset <preset>]
# 校验：bctx 必须存在于 docs/architecture/_context-map.yaml；服务命名 svc-<NN>-<bctx>-<role>

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TYPE=""
NAME=""
BCTX=""
PRESET="node-ts-postgres"

log()  { printf '\033[1;34m[new-service]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)   TYPE="$2"; shift 2 ;;
    --name)   NAME="$2"; shift 2 ;;
    --bctx)   BCTX="$2"; shift 2 ;;
    --preset) PRESET="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | head -8; exit 0 ;;
    *) err "未知参数: $1"; exit 2 ;;
  esac
done

[[ -n "$TYPE" && -n "$NAME" && -n "$BCTX" ]] || { err "--type --name --bctx 必填"; exit 2; }
[[ "$TYPE" =~ ^(api|worker|saga)$ ]] || { err "--type 必须是 api|worker|saga"; exit 2; }

cd "$ROOT"

# --- 校验 bctx 是否存在于 context-map ---------------------------
CTXMAP="docs/architecture/_context-map.yaml"
[[ -f "$CTXMAP" ]] || { err "缺少 $CTXMAP（先运行 scaffold.sh 渲染模板）"; exit 2; }
if ! grep -E "^\s*-\s*id:\s*${BCTX}\s*$" "$CTXMAP" >/dev/null; then
  err "BC '$BCTX' 未在 $CTXMAP 注册；请先 ADR + 注册再 new-service"
  exit 2
fi

# --- 选择服务编号 ---------------------------------------------
EXISTING=$(ls apps 2>/dev/null | grep -E "^svc-[0-9]+-${BCTX}-" || true)
NEXT_NN=$(printf '%02d' $(($(echo "$EXISTING" | grep -c '^svc-') + 1)))
SERVICE="svc-${NEXT_NN}-${BCTX}-${TYPE}"
DEST="apps/$SERVICE"

[[ -e "$DEST" ]] && { err "$DEST 已存在"; exit 2; }

log "创建 $DEST  (preset=$PRESET)"
mkdir -p "$DEST"
# 从 _template 复制基线
cp -R apps/_template/* "$DEST/" 2>/dev/null || true
# 从 preset 注入（README 占位）
PRESET_DIR="apps/_stack-presets/$PRESET"
[[ -d "$PRESET_DIR" ]] || { err "未知 preset: $PRESET"; exit 2; }
cp "$PRESET_DIR/README.md" "$DEST/PRESET.md"

# --- 提示更新 _registry.yaml ----------------------------------
log "✅ 已创建 $DEST"
log "❗下一步（手动）："
log "  1) 在 docs/architecture/_registry.yaml 的 services: 下新增 $SERVICE 节点"
log "  2) 在 contracts/$BCTX/ 提案契约（openapi/asyncapi）"
log "  3) 跑 git add + 提交"
