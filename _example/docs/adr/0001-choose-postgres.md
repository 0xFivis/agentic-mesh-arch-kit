<!-- REFERENCE ONLY: sanitized sample, not for production -->
# ADR-0001 · Choose PostgreSQL as primary OLTP

- **Status**: accepted
- **Date**: 2025-01-15
- **Deciders**: <team-lead>, <architect>

## Context

需要为 `<bctx-orders>` 选 OLTP 数据库。候选：PostgreSQL / MySQL / CockroachDB。

## Decision

选 PostgreSQL 16。

## Consequences

- 正面：JSONB、partial index、生态成熟、团队熟。
- 负面：水平扩展需 Citus / 分片中间件，未来若 QPS > X 需复盘。
- 触发再评估的指标：写 TPS > 20k · 数据量 > 5 TB。

## Alternatives considered

| 候选 | 优势 | 劣势 | 否决理由 |
|------|------|------|---------|
| MySQL 8 | 普及度 | JSON / 复杂查询弱 | 业务有大量 JSON 字段 |
| CockroachDB | 原生分布式 | 团队不熟 / 成本高 | 当前 QPS 远未到瓶颈 |

## Linked

- 影响章节：`docs/architecture/04_data-architecture.md`
- 影响服务：`svc-01-bctx-orders-api`
