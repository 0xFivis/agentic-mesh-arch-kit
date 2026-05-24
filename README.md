# agentic-mesh-arch-kit

> **⚠ 状态：早期草案 / Early Draft · Not production-ready**
>
> 本仓仍在完善与测试中，**不是正式发布的项目**：内容存在缺失、模板与 CI 覆盖不全、边角场景未验证、技术债较多。仅适合**评估、试用、提反馈**，**不建议直接用于生产**。API / 脚本参数 / 目录结构可能随时变动且不保证向后兼容。
>
> *This repository is an early draft and not officially released. Expect missing content, incomplete CI/template coverage, unverified edge cases, and notable tech debt. Use for evaluation and feedback only; not recommended for production. APIs, script flags, and layout may change without notice.*

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

## Install

### Quick start — remote one-liner (no clone)

```bash
mkdir my-platform && cd my-platform
bash <(curl -sSL https://raw.githubusercontent.com/0xFivis/agentic-mesh-arch-kit/main/bootstrap.sh) --name my-platform
```

The bootstrap script shallow-clones the kit to a tempdir, runs `scripts/scaffold.sh` against your current directory, and cleans up. All `scaffold.sh` flags pass through (`--with-examples`, `--dry-run`, …).

Pin a version: `KIT_REF=v0.2.0 bash <(curl -sSL …/bootstrap.sh) --name my-platform`
Use a fork: `KIT_REPO=https://github.com/you/agentic-mesh-arch-kit.git bash <(curl -sSL …/bootstrap.sh) --name my-platform`

For `new-service.sh` / `upgrade-arch-kit.sh` you still need the kit on disk — see "Get the kit" below.

### Prerequisites

- `git` ≥ 2.30
- `bash` ≥ 3.2 (macOS stock works; Linux/WSL fine)
- `make` (optional, for aggregated targets)

### 1 · Get the kit

```bash
git clone https://github.com/fivis/agentic-mesh-arch-kit.git ~/.agentic-mesh-arch-kit
```

> Pin a version (recommended for reproducibility):
> ```bash
> git -C ~/.agentic-mesh-arch-kit checkout v0.1.0
> ```

### 2 · Scaffold a new platform

```bash
mkdir my-platform && cd my-platform
bash ~/.agentic-mesh-arch-kit/scripts/scaffold.sh --name my-platform
```

Flags:

| Flag | Effect |
|---|---|
| `--name <project-name>` | **required** — substitutes `<project-name>` placeholders |
| `--with-examples` | keep `_example/` reference samples (default: delete after render) |
| `--dry-run` | show what would happen; write nothing |

After `scaffold.sh` you get a clean skeleton + a fresh `git init` + first commit + `.arch-kit-version` pin.

### 3 · Add your first service

```bash
# bctx MUST already exist in docs/architecture/_context-map.yaml
bash ~/.agentic-mesh-arch-kit/scripts/new-service.sh \
  --type api \
  --name orders \
  --bctx bctx-orders \
  --preset node-ts-postgres
```

`--type` ∈ `api | worker | saga`
`--preset` ∈ `node-ts-postgres | python-fastapi-postgres | go-grpc-postgres | kotlin-spring-postgres`

Service is named `svc-<NN>-<bctx>-<type>` (auto-numbered).

### 4 · (Optional) Layer in AI collaboration

```bash
git clone https://github.com/fivis/agentic-mesh-ai-kit.git ~/.agentic-mesh-ai-kit
bash ~/.agentic-mesh-ai-kit/scripts/install.sh --vendor all
```

See [`agentic-mesh-ai-kit`](https://github.com/fivis/agentic-mesh-ai-kit) README for vendor-specific flags.

### 5 · Upgrade later

```bash
git -C ~/.agentic-mesh-arch-kit fetch --tags
git -C ~/.agentic-mesh-arch-kit checkout v0.2.0
bash ~/.agentic-mesh-arch-kit/scripts/upgrade-arch-kit.sh
# review git diff; resolve any *.local backups or merge conflict markers
```

The upgrade script reads `.arch-kit-version`, fetches that tag as the merge base, and performs a three-way merge against your modified files.

## Relationship with `agentic-mesh-ai-kit`

**Zero coupling.** This repo never invokes `ai-kit`, is never a submodule of it, and contains no AI-tooling files. If you want AI collaboration on top, separately run `ai-kit/scripts/install.sh` in the derived platform — it lays AI assets alongside this skeleton without touching its contents.

## Status

`v0.1.0` planned (MVP). See [`CHANGELOG.md`](CHANGELOG.md).

## License

MIT — see [`LICENSE`](LICENSE).
