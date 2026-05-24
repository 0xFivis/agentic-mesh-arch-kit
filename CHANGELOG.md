# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] — 2026-05-24

### Changed (potentially breaking for downstream)
- **`tech-standards/` flattened from per-directory READMEs to top-level single files**: `STD-01-coding.md` ... `STD-09-delivery.md` directly under `tech-standards/` (previously `docs/standards/STD-NN-xxx/README.md`)
- `docs/architecture/_registry.yaml.tmpl` moved to `docs/services/_registry.yaml.tmpl` (service registry is service-scoped, not architecture-scoped)

### Added
- `contracts/{_common,_template,AGENTS.md,README.md}` BC-first contracts scaffold at top level
- `.github/workflows/`: `build-data-index.yml`, `contracts-drift.yml`, `contracts-sync.yml` (auto data-index + contract sync CI)
- `.github/{CODEOWNERS.tmpl,PULL_REQUEST_TEMPLATE.md,ISSUE_TEMPLATE/,dependabot.yml}`
- `apps/_template/{internal,migrations,tests}/` substructure
- `ops/{alerts,runbooks,slo}/_template/`, `ops/dashboards/.gitkeep`
- `testing/{contract/_template,e2e,integration,load,fixtures}/` placeholders
- `init/{db-init.sh.tmpl, seed.sh.tmpl}`
- `compose.yaml.tmpl`, `.editorconfig`
- `docs/{TECH-DEBT.md, adr/, architecture/00_governance.md, services/README.md, services/_template/}`
- `scripts/`: `build-data-index.py`, `check-contracts-drift.py`, `check-contracts-sync.py`
- READMEs across `scripts/`, `ops/`, `testing/`, `_example/`

### Removed
- `_example/contracts/`, `_example/docs/` reference samples (consolidated into `_example/README.md`)
- Old `docs/standards/STD-NN-xxx/` directory structure (replaced by flat `tech-standards/STD-NN.md`)

### Tooling
- `.gitignore`: added `__pycache__/` and `*.pyc`

## [0.1.0] — 2026-05-22

Planned MVP release. Targets:
- 8 architecture chapter templates under `docs/architecture/`
- 9 cross-cutting standards under `tech-standards/`
- DDD bounded-context-first `contracts/` layout with `_common/` whitelist
- `apps/_template/` + 4 stack presets under `apps/_stack-presets/`
- `packages/_template/`
- `ops/{runbooks,dashboards,alerts,slo}/` + `testing/{e2e,integration,load,contract,fixtures}/` placeholders
- `init/`, `examples/` (README-only), `.tool-versions.tmpl`, `Makefile.tmpl`
- `scripts/scaffold.sh`, `scripts/new-service.sh`, `scripts/upgrade-arch-kit.sh`
- `_example/` reference samples (opt-in via `scaffold.sh --with-examples`)
