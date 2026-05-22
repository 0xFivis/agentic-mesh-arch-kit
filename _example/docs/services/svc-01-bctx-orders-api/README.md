<!-- REFERENCE ONLY: sanitized sample, not for production -->
# svc-01-bctx-orders-api · 服务详设

> 8 章模板填充样例。复制到 `docs/services/svc-NN-<bctx>-<role>/` 后改写。

## 1. 上下文（Bounded Context）
本服务承载 `<bctx-orders>` BC 的同步 API 入口。聚合根：Order。

## 2. 契约
- 提供：`contracts/bctx-orders/openapi/orders-api.v1.yaml`
- 消费：`contracts/bctx-inventory/asyncapi/stock.adjusted.v1.yaml`

## 3. Sagas
- 创建订单 Saga：本服务 orchestrator；步骤 reserve-stock → charge → confirm。

## 4. 数据模型
- 表：orders、order_items（schema 见 init/migrations/）
- 私有；其他 BC 通过事件读取。

## 5. SLO
- 可用性 99.9% · P95 < 250ms · 错误率 < 0.5%

## 6. Runbooks
- ops/runbooks/orders-api-5xx-spike.md
- ops/runbooks/orders-api-saga-stuck.md

## 7. 安全/合规
- 鉴权：bearer JWT；PII 字段 customerId 在日志中 mask。

## 8. 灾备
- RTO 5min · RPO 1min（Postgres streaming replica + 异地快照）
