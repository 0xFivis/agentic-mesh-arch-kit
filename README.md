# agentic-mesh-arch-kit

> **Project skeleton template** for polyglot, multi-service software platforms — zero AI-collaboration content, zero business domain content. Pair it with [`agentic-mesh-ai-kit`](https://github.com/fivis/agentic-mesh-ai-kit) (independent, optional) for AI-assisted development workflows.

## What this repo is

A **GitHub Template repository** that bootstraps an opinionated platform skeleton:

- `docs/architecture/` · 8 architecture chapters (bounded contexts, system landscape, service decomposition, data, compliance, integration, cross-context patterns, ADR index)
- `docs/services/` · per-service nine-piece design template + `_registry.yaml` (tactical SSOT)
- `docs/adr/` · ADR records (Michael Nygard 5-section format)
- `tech-standards/` · 9 cross-cutting standards (API / data / events / security / observability / …)
- `contracts/` · DDD-bounded-context first-level layout: `contracts/<bctx>/{openapi/<svc>, asyncapi, proto, _shared}` + `_common/` whitelist
- `apps/` · service workspaces (`_template/` + 4 stack presets under `_stack-presets/`)
- `packages/` · symmetric shared libraries
- `ops/` · `runbooks/ dashboards/ alerts/ slo/` (no `infra/` — intentionally not pre-shipped)
- `testing/` · `e2e/ integration/ load/ contract/ fixtures/` (cross-service)
- `init/`, `examples/`, `.tool-versions.tmpl`, `Makefile.tmpl`

What this repo is **not**:
- ❌ Not an AI agent / skill / prompt distribution
- ❌ Not a business-domain template (no industry-specific code or terminology)
- ❌ Not a runtime; just files + scripts

## Two ways to derive a platform from this kit

| Method | When to use |
|---|---|
| **GitHub "Use this template"** button | Greenfield project, want a fresh repo |
| **`bash scripts/scaffold.sh`** | Bootstrap into an existing empty directory |

Either path produces a clean skeleton. By default, reference samples under any `_example/` directory are stripped; pass `--with-examples` to `scaffold.sh` (or delete them manually after using the Template button) to retain them as opt-in learning material.

`scripts/new-service.sh --type <stack> --name <svc> --bctx <bounded-context>` adds a new service (the `--bctx` value MUST already be registered in `docs/architecture/_context-map.yaml`, otherwise the script aborts).

## Relationship with `agentic-mesh-ai-kit`

**Zero coupling.** This repo never invokes `ai-kit`, is never a submodule of it, and contains no AI-tooling files. If you want AI collaboration on top, separately run `ai-kit/scripts/install.sh` in the derived platform — it lays AI assets alongside this skeleton without touching its contents.

## Versioning

Derived platforms record the kit version used in a single file at the platform root:

```
.arch-kit-version   # e.g. v0.1.0
```

`scripts/upgrade-arch-kit.sh` performs a three-way merge against a newer tag and updates this file.

## Status

`v0.1.0` planned (MVP). See [`CHANGELOG.md`](CHANGELOG.md).

## License

MIT — see [`LICENSE`](LICENSE).
