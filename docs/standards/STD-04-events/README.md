<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-04 — 事件与消息

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft (MVP) | 架构组 | 0.1 | 2026-05-10 |

## 1. 总线选择

- 业务事件（Saga / 跨 BC 通知 / Outbox）：**Kafka**
- 任务队列（短期、需 ack/重试）：**RabbitMQ** 或 Kafka
- 内部低延迟广播 / pub-sub：Redis Pub/Sub（仅缓存类，**MUST NOT** 承载业务关键事件）

> 选型依据见 ADR-0011（Phase C 立）

## 2. Topic 命名

格式：`<bounded_context>.<aggregate>.<event>.v<major>`

例：
- `trading.order.placed.v1`
- `trading.order.filled.v1`
- `cash.withdrawal.requested.v1`
- `crypto.deposit.confirmed.v1`

约定：
- 全小写，点分
- BC 段使用 BC 短名（trading / cash / crypto / <identity-verification> / ib / notify / audit / quote）
- 版本号 **MUST** 在 topic 名上；破坏性变更 **MUST** 升版本并双写一段时间

## 3. 消息封装（强制 envelope）

**MUST** 用统一封装，业务负载在 `data`：

```json
{
  "event_id":      "01HX8K4Z9P5Q3R2T1V0WXYZA1B",
  "event_type":    "trading.order.filled.v1",
  "event_time":    "2026-05-10T14:30:00.123Z",
  "producer":      "trading-ledger-service",
  "trace_id":      "00-4bf92f...-00f067aa0ba902b7-01",
  "schema_url":    "https://schemas.quantix.com/trading/order/filled/v1.json",
  "idempotency_key": "<producer-defined unique key>",
  "data": {
    "order_id": "01HX...",
    "filled_qty": "1.50000000",
    "fill_price": "1850.25000000"
  }
}
```

字段说明：

| 字段 | 必填 | 说明 |
|------|------|------|
| `event_id` | MUST | 事件唯一 ID（消费者去重用）|
| `event_type` | MUST | = topic 名 |
| `event_time` | MUST | 事件**业务**发生时间（UTC ISO 8601）|
| `producer` | MUST | 生产者服务名 |
| `trace_id` | MUST | W3C traceparent，跨服务追踪 |
| `schema_url` | SHOULD | JSON Schema URL |
| `idempotency_key` | MUST | 业务幂等键（订单 ID、转账 ID 等）|
| `data` | MUST | 业务负载 |

> **运营主体归属字段**（如有）的命名与必选性见 [ADR-0006 §2.6](../../tech-docs/adr/ADR-0006-multi-tenant-isolation.md)，本 STD 不重复规定。

## 4. 幂等（消费者强制）

- 消费者 **MUST** 实现去重：基于 `event_id` 或 `idempotency_key`
- 去重窗口 **MUST** ≥ 7 天（覆盖最长重放周期）
- 去重存储建议：Redis 或专用去重表

## 5. Schema 演进

- 兼容变更（不升版本）：新增可选字段、新增枚举值
- 破坏性变更：**MUST** 升 `vN`、新建 topic、双写≥30 天、监控旧 topic 流量归零后退役
- 所有 schema **MUST** 有 JSON Schema 或 protobuf 定义，集中放 `schemas/` 仓

## 6. 顺序与分区

- 同一聚合根的事件 **MUST** 路由到同一分区（partition key = aggregate_id）
- 跨聚合 **MUST NOT** 假设全局顺序
- 消费者 **MUST** 处理乱序（用 `event_time` 决策，非到达顺序）

## 7. 死信 (DLQ)

- 每个 consumer group **MUST** 有对应 `<topic>.dlq`
- 重试策略：3 次指数退避（1s / 5s / 30s），超后入 DLQ
- DLQ **MUST** 接告警 + Runbook
- 业务关键事件（资金/交易）DLQ 积压 > 5 分钟 = P1

## 8. Outbox 模式（强制于状态变更服务）

- 服务写本地 DB 的同时 **MUST** 写 outbox 表（同事务）
- 独立 dispatcher 异步推 Kafka，推送成功后标记
- **MUST NOT** 在业务事务里直接 publish to broker（双写不一致风险）

```sql
CREATE TABLE outbox_event (
  event_id    CHAR(26) PRIMARY KEY,
  topic       VARCHAR(128) NOT NULL,
  payload     JSONB NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at TIMESTAMPTZ
);
CREATE INDEX idx_outbox_unpublished ON outbox_event(created_at) WHERE published_at IS NULL;
```

## 9. Saga 模板

- 编排 (orchestration) 模式：**MUST** 有显式 saga 状态表 + 步骤日志
- 每步 **MUST** 是幂等操作 + 有对应补偿
- 补偿失败 **MUST** 转人工（不可无限重试）
- 详细 saga 设计见各服务详设 (`tech-docs/services/SXX/saga.md`)

## 10. 事件命名词汇

- 已发生事实：过去式 + 完成体：`order.placed`、`withdrawal.approved`、`deposit.confirmed`
- **MUST NOT** 用命令式：~~`place.order`~~、~~`approve.withdrawal`~~（命令属于 RPC）
- 状态变更：`<entity>.<state>` 或 `<entity>.<verb>ed`：`order.cancelled`、`account.frozen`
