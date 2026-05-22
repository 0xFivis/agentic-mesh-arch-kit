#!/usr/bin/env bash
# agentic-mesh-arch-kit / scripts/scaffold.sh
# 用法：在目标空目录内执行
#   mkdir my-platform && cd my-platform
#   bash ~/.agentic-mesh-arch-kit/scripts/scaffold.sh --name my-platform [--with-examples] [--dry-run] [--target <dir>]
# 设计：把 kit 内容拷贝到 target → 渲染 .tmpl → git init。NO AI ACTIONS。

set -euo pipefail
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KIT_VERSION="$(cat "$KIT_ROOT/VERSION" 2>/dev/null || echo "0.1.0")"
PROJECT_NAME=""
WITH_EXAMPLES="false"
DRY_RUN="false"
TARGET="$PWD"

log()  { printf '\033[1;34m[scaffold]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)           PROJECT_NAME="$2"; shift 2 ;;
    --with-examples)  WITH_EXAMPLES="true"; shift ;;
    --dry-run)        DRY_RUN="true"; shift ;;
    --target)         TARGET="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | head -20; exit 0 ;;
    *) err "未知参数: $1"; exit 2 ;;
  esac
done

[[ -n "$PROJECT_NAME" ]] || { err "--name 必填"; exit 2; }
[[ "$KIT_ROOT" != "$TARGET" ]] || { err "拒绝就地 scaffold：target ($TARGET) 与 kit ($KIT_ROOT) 相同"; exit 2; }

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

log "项目名:    $PROJECT_NAME"
log "Kit 版本:  $KIT_VERSION"
log "Kit 路径:  $KIT_ROOT"
log "Target:    $TARGET"

# --- step 1: 拷贝 kit → target（排除元数据/脚本/示例） -----------
# 注意：rs ync 模式需以 / 开头才能锁定到源根目录，
# 否则会递归匠每个子目录同名文件（会误杀骨架 README.md）。
log "[1/4] 拷贝 kit 内容 → target"
EXCLUDES=(
  --exclude='.git'
  --exclude='/scripts'
  --exclude='/VERSION'
  --exclude='/README.md'
  --exclude='/CHANGELOG.md'
  --exclude='/LICENSE'
  --exclude='/.gitignore'
)
[[ "$WITH_EXAMPLES" == "true" ]] || EXCLUDES+=(--exclude='/_example')

if [[ "$DRY_RUN" == "true" ]]; then
  log "DRY: rsync -a ${EXCLUDES[*]} $KIT_ROOT/ $TARGET/"
else
  rsync -a "${EXCLUDES[@]}" "$KIT_ROOT/" "$TARGET/"
fi

# --- step 2: 渲染所有 .tmpl → 同名无后缀文件 -------------------
log "[2/4] 渲染 .tmpl"
RENDERED=0
SKIPPED=0
if [[ "$DRY_RUN" != "true" ]]; then
  while IFS= read -r -d '' src; do
    dst="${src%.tmpl}"
    if [[ -e "$dst" ]]; then warn "skip (exists): ${dst#$TARGET/}"; SKIPPED=$((SKIPPED+1)); continue; fi
    sed -e "s/<project-name>/${PROJECT_NAME}/g" "$src" > "$dst"
    rm -f "$src"
    RENDERED=$((RENDERED+1))
  done < <(find "$TARGET" -type f -name '*.tmpl' -not -path '*/.git/*' -print0)
fi
log "渲染完成: $RENDERED 渲染 / $SKIPPED 跳过"

# --- step 3: 写入 .arch-kit-version ---------------------------
log "[3/4] 写 .arch-kit-version"
[[ "$DRY_RUN" == "true" ]] || echo "$KIT_VERSION" > "$TARGET/.arch-kit-version"

# --- step 4: git init (若未初始化) ----------------------------
log "[4/4] git init"
if [[ -d "$TARGET/.git" ]]; then
  warn "已是 git 仓库，跳过 init"
else
  if [[ "$DRY_RUN" == "true" ]]; then
    log "DRY: git init && initial commit"
  else
    ( cd "$TARGET" && git init -q && git add -A && git commit -qm "chore: scaffold from agentic-mesh-arch-kit v$KIT_VERSION" )
  fi
fi

log "完成。下一步："
log "  1) 填写 docs/architecture/*.md 中的 <占位>"
log "  2) bash $KIT_ROOT/scripts/new-service.sh --type api --name <svc> --bctx <bctx> --preset node-ts-postgres"
log "  3) 用 agentic-mesh-ai-kit install.sh 注入 AI 协作矩阵"
