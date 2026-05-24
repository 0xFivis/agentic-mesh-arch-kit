# _example/

> Curated end-to-end examples (filled). **Reserved for v0.2+.** Currently empty.

In v0.1.x this folder is intentionally empty. Use `_template/` (under `contracts/`, `apps/`, `packages/`, `docs/services/`, `docs/adr/`, `ops/*/`, `testing/contract/`) for the **placeholder scaffold** that `scripts/new-service.sh` copies from.

`_template/` vs `_example/`:
- `_template/` = sanitized placeholders, used by scripts as copy source
- `_example/` = filled real-world examples for humans to study (planned for v0.2+)

## v0.2+ 待补清单（v6 plan D27 推迟项）

v6 plan D27 原列约 10 份 `_example/` 文件，v0.1 收敛为「`_template/` 占位 + `_example/` 待填」二分。
以下文件 v0.2+ 补齐（用虚构 `notifications` bctx + `notification-service` 串成完整端到端示例）：

- [ ] `contracts/_example-context/`（虚构 `notifications` bctx 完整结构，含 README / openapi / asyncapi / proto / _shared/）
- [ ] `docs/architecture/_example/_context-map.{yaml,md}`（2-3 个虚构 bctx + 9 种 DDD 关系样例 + Mermaid C4）
- [ ] `docs/adr/_example/ADR-0001-record-architecture-decisions.md`（Michael Nygard 经典元 ADR）
- [ ] `docs/services/_example-service/`（虚构 `notification-service` 九件套，头部 `bctx: notifications`）
- [ ] `docs/services/_registry.yaml` 示例追加 1 行（联动 `_example-service`）
- [ ] `ops/runbooks/_example/svc-5xx-spike.md`
- [ ] `ops/alerts/_example/p99-latency.yaml`
- [ ] `ops/slo/_example/availability-999.md`
- [ ] `testing/contract/_example/`（1 份 Pact 文件，消费者侧调 `_example-context/openapi/notifier-api/`）

**约定**：每文件首行必含 `<!-- REFERENCE ONLY: sanitized sample, not for production -->`，由 retro-audit skill D27 检查项强制；scaffold.sh `--with-examples` flag 在 v0.2+ 启用后才有效（v0.1 该 flag 是 no-op）。
