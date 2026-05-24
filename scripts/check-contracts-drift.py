#!/usr/bin/env python3
"""check-contracts-drift.py — W15 contracts drift detector.

检查范围（A + B）：
A) _registry.yaml.services[*].contracts.{provides,consumes} 列出的路径必须在 contracts/ 下存在
B) contracts/<bctx>/{openapi,asyncapi}/**/*.yaml 必须是合法 YAML 且含 openapi|asyncapi 顶层字段

退出码:
  0  OK
  1  drift detected
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


def check_provides_consumes(registry: dict, repo_root: Path) -> list[str]:
    """A) registry-declared contracts must exist on disk."""
    errors: list[str] = []
    for svc in registry.get("services", []) or []:
        name = svc.get("name", "<unnamed>")
        contracts = svc.get("contracts", {}) or {}
        for kind in ("provides", "consumes"):
            for rel in contracts.get(kind, []) or []:
                # Skip placeholder paths (e.g. contains <...> markers from .tmpl)
                if "<" in rel or ">" in rel:
                    continue
                p = repo_root / rel
                if not p.is_file():
                    errors.append(f"[{name}] declared {kind}: {rel} → file missing")
    return errors


def check_contract_schemas(repo_root: Path) -> list[str]:
    """B) every contracts/<bctx>/{openapi,asyncapi}/**/*.yaml must be parseable + have header."""
    errors: list[str] = []
    contracts_root = repo_root / "contracts"
    if not contracts_root.is_dir():
        return errors  # no contracts dir → nothing to check

    for yaml_file in contracts_root.rglob("*.yaml"):
        # Skip _template / _shared / _common
        if any(part.startswith("_") or part.startswith("<") for part in yaml_file.parts):
            continue
        try:
            with yaml_file.open("r", encoding="utf-8") as f:
                doc = yaml.safe_load(f)
        except yaml.YAMLError as e:
            errors.append(f"{yaml_file.relative_to(repo_root)} → YAML parse error: {e.__class__.__name__}")
            continue
        if not isinstance(doc, dict):
            errors.append(f"{yaml_file.relative_to(repo_root)} → not a mapping at top level")
            continue
        # Determine expected header by parent path
        parts = yaml_file.relative_to(contracts_root).parts
        if len(parts) >= 2:
            kind = parts[1]  # contracts/<bctx>/<kind>/...
            if kind == "openapi" and "openapi" not in doc:
                errors.append(f"{yaml_file.relative_to(repo_root)} → missing top-level 'openapi' field")
            elif kind == "asyncapi" and "asyncapi" not in doc:
                errors.append(f"{yaml_file.relative_to(repo_root)} → missing top-level 'asyncapi' field")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="W15 contracts drift check")
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
        print(f"::warning::registry not found: {registry_path} — skipping drift check")
        return 0

    registry = load_registry(registry_path)
    errors: list[str] = []
    errors.extend(check_provides_consumes(registry, repo_root))
    errors.extend(check_contract_schemas(repo_root))

    if errors:
        print(f"❌ contracts drift detected ({len(errors)} issue(s)):")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("✅ contracts drift check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
