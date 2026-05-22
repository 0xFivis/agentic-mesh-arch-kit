<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-02 — API 与契约

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft (MVP) | 架构组 | 0.1 | 2026-05-10 |

> **MVP 范围**：仅覆盖 Phase C 服务详设刚性需要的最小集；后续按需扩展。

## 1. 协议选择

| 场景 | 协议 | 依据 |
|------|------|------|
| 公共 API（移动端、Web、第三方） | REST + JSON over HTTPS | 兼容性、调试、缓存友好 |
| 内部服务间高频/低延迟 | gRPC + protobuf | 二进制、流式、强类型 |
| 实时推送（<market-data>、订单状态） | WebSocket | 双向、长连接 |
| 异步事件 | 见 [STD-04](../STD-04-events/) | — |

> 跨 BC 同步调用红线：仅同进程聚合内允许；冷路径 MUST 用事件。详见 ADR-0005。

## 2. URL 命名（REST）

- **基础 URL**：`https://api.quantix.com/<version>/<resource>`
- **版本号**：URL 段 `/v1/` 形式；MAJOR only。MINOR/PATCH 兼容变更不改路径
- **资源**：复数名词、kebab-case：`/v1/trading-accounts/{id}/orders`
- **动词**：HTTP method 表达；URL **MUST NOT** 包含动词（除少数 RPC-style：`/v1/orders/{id}:cancel`）
- **过滤/分页**：query 参数 `?limit=50&cursor=...&status=open`
- **集合分页**：游标分页 (cursor-based)，**MUST NOT** 用 offset/page

## 3. HTTP Method 语义

| Method | 幂等 | 用途 |
|--------|------|------|
| GET    | ✅ | 查询，**MUST NOT** 有副作用 |
| POST   | ❌ | 创建 / 非幂等动作（须配 Idempotency-Key 头实现幂等）|
| PUT    | ✅ | 整体替换 |
| PATCH  | ❌ | 部分更新（JSON Merge Patch 或 JSON Patch） |
| DELETE | ✅ | 删除（软删除场景下幂等）|

## 4. 错误响应（强制）

**MUST** 遵循 [RFC 7807 — Problem Details](https://datatracker.ietf.org/doc/html/rfc7807)：

```json
{
  "type": "https://errors.quantix.com/orders/insufficient-margin",
  "title": "Insufficient margin",
  "status": 422,
  "detail": "Account 01HX... has free margin 12.50 USD, requires 50.00 USD",
  "instance": "/v1/orders/01HXABCDEF",
  "code": "ORD.MARGIN.INSUFFICIENT",
  "trace_id": "00-4bf92f...-00f067aa0ba902b7-01"
}
```

字段约定：

| 字段 | 必填 | 说明 |
|------|------|------|
| `type` | MUST | 错误类型 URI（可点击查文档） |
| `title` | MUST | 短描述（不随场景变） |
| `status` | MUST | HTTP 状态码（数字） |
| `code` | MUST | 平台内错误码 `<DOMAIN>.<CATEGORY>.<REASON>` 三段式大写点分 |
| `detail` | SHOULD | 当前实例的具体说明（可含变量） |
| `instance` | SHOULD | 触发错误的资源路径 |
| `trace_id` | MUST | W3C Trace Context traceparent，便于跨服务定位 |

错误码命名空间登记表见 [error-codes.md](./error-codes.md)。

## 5. 幂等

- 所有 **非幂等写操作（POST + 资金/交易类）MUST** 接受 `Idempotency-Key` 请求头
- Key 格式：客户端生成的 ULID 或 UUIDv4
- 服务端 **MUST** 缓存（key, response）至少 24h
- 同 key 重复请求 **MUST** 返回首次响应（不重复执行业务逻辑）

## 6. 时间与时区

- 所有时间字段 **MUST** 是 ISO 8601 UTC：`2026-05-10T14:30:00.123Z`
- **MUST NOT** 使用本地时间或带 offset 的格式
- 业务日 (`business_date`) 字段 **MUST** 是 `YYYY-MM-DD`，UTC 日界（见 ADR-0008）

## 7. 标识符

| 类型 | 格式 | 示例 |
|------|------|------|
| 资源主键 | ULID（26 字符）| `01HX8K4Z9P5Q3R2T1V0WXYZA1B` |
| 链上交易 | 原始 hash | — |
| 客户端关联 ID | 客户端自定义字符串，长度 ≤64 | `client_ref=order-abc-123` |

**MUST NOT** 暴露内部自增 ID。

## 8. 版本与兼容

- **兼容变更**（不升版本）：新增字段、新增可选 query、新增可选 header、新增枚举值（消费者 MUST 容忍未知值）
- **破坏性变更**（升 v1→v2）：删除/重命名字段、改变字段类型、删除枚举值、改变错误码语义
- 旧版本 **MUST** 保留至少 12 个月或所有客户端迁移完成（取较长者）

## 9. OpenAPI / proto

- REST 服务 **MUST** 提供 OpenAPI 3.1 spec，置于服务仓 `api/openapi.yaml`
- gRPC 服务 **MUST** 提供 `.proto` 置于 `api/proto/`，用 `buf` 管理 lint + breaking change check
- Spec **MUST** 是契约源 (source of truth)，代码从 spec 生成 (codegen)

## 10. 速率限制

- 公共 API **MUST** 返回 `RateLimit-Limit` / `RateLimit-Remaining` / `RateLimit-Reset` 标准头（IETF draft）
- 超限返回 `429 Too Many Requests` + Problem Details

## 11. 安全头（公共 API）

**MUST** 包含：
- `Strict-Transport-Security: max-age=63072000; includeSubDomains; preload`
- `X-Content-Type-Options: nosniff`
- `Cache-Control: no-store`（资金/交易类）
- 详见 [STD-05](../STD-05-security/)
