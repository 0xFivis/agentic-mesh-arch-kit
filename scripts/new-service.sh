#!/usr/bin/env bash
# agentic-mesh-arch-kit / scripts/new-service.sh
# 用法：cd <消费仓> && bash <arch-kit>/scripts/new-service.sh \
#         --type <api|worker|saga|gateway> --name <short-name> --bctx <bctx-id> \
#         [--preset <preset>] [--target <dir>]
# 校验：bctx 必须存在于 <target>/docs/architecture/_context-map.yaml；服务命名 svc-<NN>-<bctx>-<role>
# 文件矩阵（详 docs/architecture/00_governance.md §5.2）：
#   api      → README + runbook + non-functional + api + events
#   worker   → README + runbook + non-functional + events + state-machine
#   saga     → README + runbook + non-functional + saga + events + state-machine
#   gateway  → README + runbook + non-functional + api

set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${TARGET:-$PWD}"
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
    --target) TARGET="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | head -14; exit 0 ;;
    *) err "未知参数: $1"; exit 2 ;;
  esac
done

[[ -n "$TYPE" && -n "$NAME" && -n "$BCTX" ]] || { err "--type --name --bctx 必填"; exit 2; }
[[ "$TYPE" =~ ^(api|worker|saga|gateway)$ ]] || { err "--type 必须是 api|worker|saga|gateway"; exit 2; }

# --- 文件矩阵：按 --type 决定 docs/services/<svc>/ 装哪些文件 ---
# 3 强制：README + runbook + non-functional；4 按需：api / events / saga / state-machine
case "$TYPE" in
  api)     MATRIX=(README runbook non-functional api events) ;;
  worker)  MATRIX=(README runbook non-functional events state-machine) ;;
  saga)    MATRIX=(README runbook non-functional saga events state-machine) ;;
  gateway) MATRIX=(README runbook non-functional api) ;;
esac

mkdir -p "$TARGET" && TARGET="$(cd "$TARGET" && pwd)"
# 守卫：仅当 KIT_ROOT 是真正的 kit 仓（含 scripts/scaffold.sh）时，才禁止 TARGET==KIT_ROOT。
# 投递到消费仓的 .arch-kit/new-service.sh 不含 scaffold.sh，跳过此守卫。
if [[ -f "$KIT_ROOT/scripts/scaffold.sh" && "$TARGET" == "$KIT_ROOT" ]]; then
  err "拒绝在 arch-kit 自身建服务：TARGET ($TARGET) 与 KIT_ROOT 相同。请 cd 到消费仓后再跑，或加 --target <消费仓>。"
  exit 3
fi
cd "$TARGET"
log "Target: $TARGET"

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

# Bug fix：preset 必须在 mkdir 之前验证，否则失败会遗留鬼目录并括位占 NN。
PRESET_DIR="apps/_stack-presets/$PRESET"
[[ -d "$PRESET_DIR" ]] || PRESET_DIR="$KIT_ROOT/apps/_stack-presets/$PRESET"
[[ -d "$PRESET_DIR" ]] || { err "未知 preset: $PRESET"; exit 2; }

log "创建 $DEST  (preset=$PRESET)"
mkdir -p "$DEST"
# 从 _template 复制基线（优先用 target 本地骨架，缺则回退到 KIT_ROOT）
TPL_DIR="apps/_template"
[[ -d "$TPL_DIR" ]] || TPL_DIR="$KIT_ROOT/apps/_template"
cp -R "$TPL_DIR"/* "$DEST/" 2>/dev/null || true
cp "$PRESET_DIR/README.md" "$DEST/PRESET.md"

# --- 实例化 contracts/<bctx>/ 骨架（仅当尚未存在） ------------
CONTRACTS_BCTX="contracts/$BCTX"
CONTRACTS_TPL="contracts/_template/<bounded-context>"
[[ -d "$CONTRACTS_TPL" ]] || CONTRACTS_TPL="$KIT_ROOT/contracts/_template/<bounded-context>"
if [[ ! -d "$CONTRACTS_BCTX" ]]; then
  log "实例化 $CONTRACTS_BCTX (from _template)"
  mkdir -p "$CONTRACTS_BCTX"
  cp -R "$CONTRACTS_TPL"/. "$CONTRACTS_BCTX/"
  # 重命名占位符目录 <svc>
  if [[ -d "$CONTRACTS_BCTX/openapi/<svc>" ]]; then
    mv "$CONTRACTS_BCTX/openapi/<svc>" "$CONTRACTS_BCTX/openapi/$NAME"
  fi
  # 占位符替换
  find "$CONTRACTS_BCTX" -type f \( -name '*.yaml' -o -name '*.proto' -o -name '*.md' \) \
    -exec sed -i.bak \
      -e "s/<bounded-context>/$BCTX/g" \
      -e "s/<bounded_context>/${BCTX//-/_}/g" \
      -e "s/<svc>/$NAME/g" \
      {} \;
  find "$CONTRACTS_BCTX" -name '*.bak' -delete
else
  log "$CONTRACTS_BCTX 已存在，跳过 _template 实例化"
fi

# --- 实例化 docs/services/<svc>/ 文件矩阵 -----------------------
DOCS_SVC="docs/services/$SERVICE"
DOCS_TPL="docs/services/_template"
# Bug fix：scaffold 已将本地 _template 的 .md.tmpl 渲染为 .md；但本脚本仍需 .md.tmpl 作为起点。
# 判断依据从 “目录存在” 改为 “.md.tmpl 文件是否存在”，本地缺失时回退到 KIT_ROOT。
compgen -G "$DOCS_TPL/*.md.tmpl" >/dev/null 2>&1 || DOCS_TPL="$KIT_ROOT/docs/services/_template"
if [[ ! -d "$DOCS_SVC" ]]; then
  log "实例化 $DOCS_SVC (type=$TYPE → ${#MATRIX[@]} 文件: ${MATRIX[*]})"
  mkdir -p "$DOCS_SVC"
  for stem in "${MATRIX[@]}"; do
    f="$DOCS_TPL/${stem}.md.tmpl"
    [[ -f "$f" ]] || { err "模板缺失: $f"; exit 2; }
    sed \
      -e "s/<bounded-context>/$BCTX/g" \
      -e "s/<svc>/$NAME/g" \
      "$f" > "$DOCS_SVC/${stem}.md"
  done
fi

# --- 提示更新 _registry.yaml ----------------------------------
log "✅ 已创建 $DEST"
log "❗下一步（手动）："
log "  1) 在 docs/services/_registry.yaml 的 services: 下新增 $SERVICE 节点（name/bctx/role/owner/repo/runtime/slo/contracts）"
log "  2) 填充 $CONTRACTS_BCTX/openapi/$NAME/v1/api.yaml 与 asyncapi/v1/events.yaml"
log "  3) 填充 $DOCS_SVC/ 文件矩阵（${MATRIX[*]}）"
log "  4) 跑 scripts/build-data-index.py 生成 $DOCS_SVC/_data-index.md（AUTO，禁手改）"
log "  5) 跑 git add + 提交"
