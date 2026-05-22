# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versioning follows [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial repository scaffolding (README, LICENSE, CHANGELOG placeholders).

## [0.1.0] — TBD

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
