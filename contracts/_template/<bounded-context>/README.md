<!-- REFERENCE ONLY: sanitized template, fill before use -->
# Bounded Context: `<bounded-context>`

> 由 `scripts/new-service.sh --bctx <bounded-context>` 实例化时，将占位符替换为真实 bctx 名。

## Ubiquitous Language（领域词表）

| 术语 | 中文 | 定义 | 备注 |
|---|---|---|---|
| `<Entity>` | <实体中文> | <一句话定义> | 例：聚合根 / 值对象 |
| ... | | | |

## 上下游关系（Context Map · 引 `docs/architecture/_context-map.yaml`）

- **上游（提供者）**：`<upstream-bctx>` · 关系 = `<Customer-Supplier|Conformist|...>`
- **下游（消费者）**：`<downstream-bctx>` · 关系 = `<...>`
- **ACL 位置**：`apps/<svc>/internal/acl/<upstream-bctx>/`（跨 bctx 翻译层）

## 服务清单

| 服务 | 类型 | 主要契约 |
|---|---|---|
| `<svc>` | `api\|worker\|saga` | `openapi/<svc>/v1/api.yaml` |

## 事件清单（bctx 粒度，非服务粒度）

| 事件类型 | 触发条件 | 负载 schema |
|---|---|---|
| `<bounded-context>.<entity>.<action>.v1` | <何时发出> | `asyncapi/v1/events.yaml#/components/messages/...` |

## 红线

- 跨 bctx 调用：必经 `apps/<svc>/internal/acl/`
- 共享类型：仅 `contracts/_common/` 白名单，业务概念禁入
- 命名空间 = `<bounded-context>` = CODEOWNERS 锁
