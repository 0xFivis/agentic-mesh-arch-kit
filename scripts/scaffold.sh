#!/usr/bin/env bash
# agentic-mesh-arch-kit / scripts/scaffold.sh
# 用法：bash scripts/scaffold.sh --name <project-name> [--with-examples] [--dry-run]
# 设计：渲染 .tmpl → 同名无后缀文件；git init；默认删除 _example/。NO AI ACTIONS。

set -euo pipefail
KIT_VERSION="$(cat "$(dirname "$0")/../VERSION" 2>/dev/null || echo "0.1.0")"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME=""
WITH_EXAMPLES="false"
DRY_RUN="false"

log()  { printf '\033[1;34m[scaffold]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)           PROJECT_NAME="$2"; shift 2 ;;
    --with-examples)  WITH_EXAMPLES="true"; shift ;;
    --dry-run)        DRY_RUN="true"; shift ;;
    -h|--help) grep '^#' "$0" | head -10; exit 0 ;;
    *) err "未知参数: $1"; exit 2 ;;
  esac
done

[[ -n "$PROJECT_NAME" ]] || { err "--name 必填"; exit 2; }

cd "$ROOT"
log "项目名: $PROJECT_NAME"
log "Kit 版本: $KIT_VERSION"

# --- step 1: 渲染所有 .tmpl → 同名无后缀文件 -------------------
log "[1/4] 渲染 .tmpl"
TMPLS=$(find . -type f -name '*.tmpl' -not -path './.git/*')
RENDERED=0
for src in $TMPLS; do
  dst="${src%.tmpl}"
  if [[ -e "$dst" ]]; then warn "skip (exists): $dst"; continue; fi
  if [[ "$DRY_RUN" == "true" ]]; then
    log "DRY: render $src → $dst"; continue
  fi
  # 简单替换：<project-name> → $PROJECT_NAME；其余占位保留供用户填写
  sed -e "s/<project-name>/${PROJECT_NAME}/g" "$src" > "$dst"
  RENDERED=$((RENDERED+1))
done
log "渲染完成: $RENDERED 个文件"

# --- step 2: 删除 _example/（除非 --with-examples） ------------
if [[ "$WITH_EXAMPLES" == "true" ]]; then
  log "[2/4] 保留 _example/ (--with-examples)"
else
  log "[2/4] 删除 _example/"
  [[ "$DRY_RUN" == "true" ]] || rm -rf _example
fi

# --- step 3: 写入 .arch-kit-version ---------------------------
log "[3/4] 写 .arch-kit-version"
[[ "$DRY_RUN" == "true" ]] || echo "$KIT_VERSION" > .arch-kit-version

# --- step 4: git init (若未初始化) ----------------------------
log "[4/4] git init"
if [[ -d .git ]]; then
  warn "已是 git 仓库，跳过 init"
else
  if [[ "$DRY_RUN" == "true" ]]; then
    log "DRY: git init && initial commit"
  else
    git init -q
    git add -A
    git commit -qm "chore: scaffold from agentic-mesh-arch-kit v$KIT_VERSION"
  fi
fi

log "完成。下一步："
log "  1) 填写 docs/architecture/*.md 中的 <占位>"
log "  2) 跑 scripts/new-service.sh 创建首个服务"
log "  3) 用 agentic-mesh-ai-kit install.sh 注入 AI 协作矩阵"
