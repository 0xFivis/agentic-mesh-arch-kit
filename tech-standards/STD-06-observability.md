<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-06 — 可观测性

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft (MVP) | 平台组 | 0.1 | 2026-05-10 |

## 1. 三大支柱

| 支柱 | 工具 | 用途 |
|------|------|------|
| Logs | Loki / OpenSearch | 故障排查、审计 |
| Metrics | Prometheus + Grafana | SLO/SLI、告警、容量 |
| Traces | Tempo / Jaeger | 跨服务延迟分解、依赖图 |

> 选型最终见 ADR-0014（Phase C 立）

## 2. 结构化日志（强制）

- **MUST** JSON 结构，**MUST NOT** 纯文本
- **MUST** 输出到 stdout（K8s 收集），**MUST NOT** 写本地文件
- 必备字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `timestamp` | ISO 8601 UTC | 日志时间 |
| `level` | string | DEBUG/INFO/WARN/ERROR |
| `service` | string | 服务名 |
| `version` | string | 服务版本（git short hash）|
| `trace_id` | string | W3C traceparent |
| `span_id` | string | 当前 span |
| `user_id` | string | 涉及用户时（**MUST NOT** 含 PII）|
| `message` | string | 人类可读消息 |
| `error` | object | 错误时含 `type` / `message` / `stack` |

> 业务归属字段（如运营主体归属）未在上表；如需在日志中携带，字段名以其所属 ADR 为准（如运营主体见 [ADR-0006 §2.6](../../tech-docs/adr/ADR-0006-multi-tenant-isolation.md)）。

- **MUST NOT** 在日志中输出：密码、Token、私钥、银行卡、身份证、API secret

## 3. Metrics 命名

格式：`<service>_<subject>_<unit>` （Prometheus 风格）

例：
- `trading_orders_placed_total{status="success", entity="OE-FCA-001"}` (counter)
- `trading_order_latency_seconds{quantile="0.99"}` (histogram)
- `cash_ledger_balance_usd{account_type="customer"}` (gauge)

约定：
- 单位后缀强制：`_total` / `_seconds` / `_bytes` / `_ratio`
- 高基数标签禁止（`user_id`、`order_id` **MUST NOT** 作 label）
- 主体标签 `entity` 允许（卡数 < 50）

## 4. Tracing

- **MUST** 用 OpenTelemetry SDK
- 入口服务 **MUST** 生成 traceparent 并透传
- 跨进程 **MUST** 传播 W3C Trace Context（HTTP `traceparent` 头 / Kafka header）
- 关键 span 属性：`http.method` / `http.status_code` / `db.system` / `messaging.system` 等遵循 OTel 语义约定
- 采样率：基线 1%，错误 100%，慢请求（>p99）100%

## 5. SLI / SLO

每个服务 **MUST** 在 `non-functional.md` 定义至少：

| 类别 | SLI | SLO 模板 |
|------|-----|---------|
| 可用性 | 成功率 | 99.9% / 30 天 |
| 延迟 | p95 / p99 | 因服务而异，详见各服务 |
| 正确性 | 业务正确率（如对账匹配率）| 99.99% |
| 数据新鲜度 | 数据滞后 | 因场景而异 |

## 6. 告警

| 严重度 | 响应时间 | 渠道 |
|-------|---------|------|
| P1 | ≤5 min | 电话 + IM + Email |
| P2 | ≤30 min | IM + Email |
| P3 | ≤4 h | Email |
| P4 | next business day | Email / Ticket |

- 每个告警 **MUST** 链接到 Runbook
- 静态阈值告警 **MUST** 标 `static`；基于 SLO burn rate 的告警 **MUST** 标 `slo`
- **MUST NOT** 配置无 owner 的告警

## 7. Trace ID 透传链路

```
Client → API Gateway → BFF → Service A → Kafka → Service B → DB
   ↓        ↓            ↓        ↓         ↓        ↓
  生成    透传         透传     透传      透传     透传
```

任何一环断链 = bug，**MUST** 修。

## 8. 敏感数据脱敏

- 邮箱：`a***@example.com`
- 手机：`+86 138****1234`
- 身份证：仅记录 hash，**MUST NOT** 入日志
- 金额：可记录但 **MUST** 标 entity 用于审计追溯
