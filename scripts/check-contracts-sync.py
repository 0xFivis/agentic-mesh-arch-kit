#!/usr/bin/env python3
"""check-contracts-sync.py — W16 cross-consistency checker.

检查范围（D + E）：
D) _registry.yaml.services[*].name 与 apps/svc-*/ 目录双向 parity
   - registry 中有的 svc，apps/ 必须有同名目录
   - apps/ 下的 svc-* 目录，registry 中必须有同名服务
E) _registry.yaml.events[*] 与 services parity
   - publisher 必须是已注册 service.name
   - subscribers[*] 必须都是已注册 service.name
   - schema 路径必须存在（与 W15 互补，这里聚焦事件视角）

退出码:
  0  OK
  1  inconsistency detected
  2  configuration / path error
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML not installed. Run: pip install pyyaml", file=sys.stderr)
    sys.exit(2)


def load_registry(registry_path: Path) -> dict:
    if not registry_path.is_file():
        print(f"ERROR: registry not found: {registry_path}", file=sys.stderr)
        sys.exit(2)
    with registry_path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def is_placeholder(name: str) -> bool:
    return "<" in name or ">" in name


def check_services_apps_parity(registry: dict, repo_root: Path) -> list[str]:
    errors: list[str] = []
    apps_root = repo_root / "apps"

    registry_names = {
        s.get("name", "") for s in (registry.get("services") or [])
        if s.get("name") and not is_placeholder(s.get("name", ""))
    }

    if not apps_root.is_dir():
        if registry_names:
            errors.append(f"apps/ directory missing but registry declares {len(registry_names)} services")
        return errors

    apps_names = {
        p.name for p in apps_root.iterdir()
        if p.is_dir() and p.name.startswith("svc-")
    }

    only_registry = registry_names - apps_names
    only_apps = apps_names - registry_names

    for name in sorted(only_registry):
        errors.append(f"[D] registry declares {name} but apps/{name}/ missing")
    for name in sorted(only_apps):
        errors.append(f"[D] apps/{name}/ exists but registry has no entry")

    return errors


def check_events_consistency(registry: dict, repo_root: Path) -> list[str]:
    errors: list[str] = []
    registry_names = {
        s.get("name", "") for s in (registry.get("services") or [])
        if s.get("name") and not is_placeholder(s.get("name", ""))
    }

    for ev in registry.get("events") or []:
        ev_id = ev.get("id", "<unnamed>")
        if is_placeholder(ev_id):
            continue

        pub = ev.get("publisher")
        if pub and not is_placeholder(pub) and pub not in registry_names:
            errors.append(f"[E] event {ev_id}: publisher '{pub}' not in services[]")

        for sub in ev.get("subscribers") or []:
            if is_placeholder(sub):
                continue
            if sub not in registry_names:
                errors.append(f"[E] event {ev_id}: subscriber '{sub}' not in services[]")

        schema = ev.get("schema")
        if schema and not is_placeholder(schema):
            if not (repo_root / schema).is_file():
                errors.append(f"[E] event {ev_id}: schema path missing → {schema}")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="W16 contracts/services sync check")
    parser.add_argument("--repo-root", default=".", help="repository root (default: cwd)")
    parser.add_argument(
        "--registry",
        default="docs/services/_registry.yaml",
        help="path to _registry.yaml relative to --repo-root",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    registry_path = repo_root / args.registry

    if not registry_path.is_file():
        print(f"::warning::registry not found: {registry_path} — skipping sync check")
        return 0

    registry = load_registry(registry_path)
    errors: list[str] = []
    errors.extend(check_services_apps_parity(registry, repo_root))
    errors.extend(check_events_consistency(registry, repo_root))

    if errors:
        print(f"❌ contracts/services sync issues ({len(errors)}):")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("✅ contracts/services sync check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
