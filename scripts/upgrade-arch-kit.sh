#!/usr/bin/env bash
# agentic-mesh-arch-kit / scripts/upgrade-arch-kit.sh
# 升级使用本 kit 生成的项目：三方合并（基线 = 上次 kit 版本；用户改动 = 现状；新版 = 当前 kit）
# 用法：bash scripts/upgrade-arch-kit.sh [--from <old-version>] [--dry-run]

set -euo pipefail
KIT_VERSION="$(cat "$(dirname "$0")/../VERSION" 2>/dev/null || echo "0.1.0")"
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${TARGET:-$PWD}"
DRY_RUN="false"
FROM_VERSION=""

log()  { printf '\033[1;34m[upgrade-arch]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)    FROM_VERSION="$2"; shift 2 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --target)  TARGET="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | head -8; exit 0 ;;
    *) err "未知参数: $1"; exit 2 ;;
  esac
done

cd "$TARGET"
[[ -f .arch-kit-version ]] || { err "缺少 .arch-kit-version；请先 scripts/scaffold.sh"; exit 2; }
CURRENT="$(cat .arch-kit-version | tr -d '[:space:]')"
[[ -z "$FROM_VERSION" ]] && FROM_VERSION="$CURRENT"

log "目标: $TARGET  · 已装 $CURRENT → 新 $KIT_VERSION"
[[ "$CURRENT" == "$KIT_VERSION" ]] && { warn "版本一致，无需升级"; exit 0; }

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
BASE="$WORK/base"; NEW="$WORK/new"; mkdir -p "$BASE" "$NEW"
if git -C "$KIT_ROOT" rev-parse "v$FROM_VERSION" >/dev/null 2>&1; then
  git -C "$KIT_ROOT" archive "v$FROM_VERSION" | tar -x -C "$BASE"
else
  warn "未找到 git tag v$FROM_VERSION；用当前 kit 作为基线（合并质量降级）"
  cp -R "$KIT_ROOT/." "$BASE/"
fi
cp -R "$KIT_ROOT/." "$NEW/"

# 候选合并范围：docs/architecture/* + tech-standards/* + Makefile + .tool-versions
declare -a SCAN_DIRS=("docs/architecture" "tech-standards")

merge_file() {
  local rel="$1"
  local base_src="$BASE/$rel" new_src="$NEW/$rel" user="$TARGET/${rel%.tmpl}"
  [[ -f "$new_src" ]] || return
  local user_path
  if [[ "$rel" == *.tmpl ]]; then user_path="$TARGET/${rel%.tmpl}"; else user_path="$TARGET/$rel"; fi
  if [[ ! -f "$user_path" ]]; then
    log "+ 新增 $user_path"
    [[ "$DRY_RUN" == "true" ]] || { mkdir -p "$(dirname "$user_path")"; cp "$new_src" "$user_path"; }
    return
  fi
  if cmp -s "$user_path" "$new_src"; then log "= $user_path"; return; fi
  if [[ -f "$base_src" ]] && cmp -s "$user_path" "$base_src"; then
    log "↑ $user_path (未改动，升级到新版)"
    [[ "$DRY_RUN" == "true" ]] || cp "$new_src" "$user_path"
    return
  fi
  log "⚡ $user_path (三方合并)"
  [[ "$DRY_RUN" == "true" ]] && return
  cp "$user_path" "$user_path.local"
  if [[ -f "$base_src" ]]; then
    git merge-file -L user -L base -L new "$user_path" "$base_src" "$new_src" \
      && log "  ✓ 干净合并" \
      || warn "  ✗ 冲突 $user_path；备份 .local"
  else
    warn "  无基线版本，写为 $user_path.new；请手动 diff"
    cp "$new_src" "$user_path.new"
  fi
}

for dir in "${SCAN_DIRS[@]}"; do
  [[ -d "$NEW/$dir" ]] || continue
  while IFS= read -r f; do
    rel="${f#$NEW/}"
    merge_file "$rel"
  done < <(find "$NEW/$dir" -type f)
done

# 单文件
for f in Makefile.tmpl .tool-versions.tmpl docs/prd/README.md apps/_stack-presets/README.md; do
  [[ -f "$NEW/$f" ]] && merge_file "$f"
done

if [[ "$DRY_RUN" != "true" ]]; then
  echo "$KIT_VERSION" > .arch-kit-version
  log "+ .arch-kit-version = $KIT_VERSION"
fi
log "完成。审阅 git diff + 解决 .local / .new 备份"
