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
| 异步事件 | 见 [STD-04](./STD-04-events.md) | — |

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

错误码命名空间登记表见下文 **§12 附录：错误码命名空间登记表**。

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
- 详见 [STD-05](./STD-05-security.md)

---

## 12. 附录：错误码命名空间登记表

> 平台错误码格式：`<DOMAIN>.<CATEGORY>.<REASON>` 三段式，全大写点分。
> 详见上文 **§4 错误响应**。

### 12.1 DOMAIN 登记表（一服务一域，已登记）

| DOMAIN | 中文 | 所属服务 / BC | 维护方 |
|--------|------|--------------|--------|
| `IDN` | 身份与认证 | identity-service / auth-service | Identity 团队 |
| `<identity-verification>` | 实名认证 | <identity-verification>-service | Compliance 团队 |
| `ACC` | 账户与持仓 | account-service | Account 团队 |
| `ORD` | 交易订单 | order-service / trading-engine | Trading 团队 |
| `LDG` | 交易账本 | trading-ledger-service | Trading 团队 |
| `RSK` | 风控 | risk-service | Risk 团队 |
| `FND` | 资金（入金/出金/划转）| funding-service | Funding 团队 |
| `WLT` | 加密钱包 | crypto-wallet-service | Wallet 团队 |
| `MKT` | <market-data> | market-data-service | Market 团队 |
| `<external-system>` | <external-system> 桥接 | <external-system>-bridge-service | Integration 团队 |
| `IB` | IB 代理 | ib-service | IB 团队 |
| `CPY` | <social-feature> | <social-feature>-service | Social 团队 |
| `NTF` | 通知 | notification-service | Platform 团队 |
| `FIL` | 文件存储 | file-service | Platform 团队 |
| `RPT` | 监管报送 | reporting-service | Compliance 团队 |
| `SYS` | 平台基础（网关 / 限流 / 鉴权基础设施）| api-gateway / 横切 | Platform 团队 |

> **新增 DOMAIN 必须**：(1) PR 修改本表 (2) 三段式不与现有撞名 (3) 通过 Standards WG review。

### 12.2 CATEGORY 标准枚举（跨域统一）

| CATEGORY | 含义 | HTTP 默认 |
|----------|------|----------|
| `VALIDATION` | 入参格式 / 取值非法 | 400 |
| `AUTH` | 未认证 / token 无效 | 401 |
| `PERMISSION` | 已认证但无权限 / 主体隔离命中 | 403 |
| `NOT_FOUND` | 资源不存在 | 404 |
| `CONFLICT` | 业务态冲突（重复 / 状态机不允许） | 409 |
| `PRECONDITION` | 前置条件不满足（如 <identity-verification> 未通过、余额不足）| 422 |
| `RATE_LIMIT` | 限流命中 | 429 |
| `DEPENDENCY` | 下游依赖不可用（LP / <external-system> / 链上）| 502 / 503 |
| `INTERNAL` | 服务内部错误（不暴露细节） | 500 |
| `TIMEOUT` | 请求或下游超时 | 504 |

### 12.3 REASON 命名约定

- 单数名词或动名短语，全大写下划线
- 例：`INSUFFICIENT_BALANCE` / `<identity-verification>_NOT_APPROVED` / `ORDER_ALREADY_FILLED` / `SYMBOL_HALTED`
- 不在 `code` 中暴露内部实现细节（schema 名 / 内部字段名）

### 12.4 完整码示例

| 错误码 | 含义 | HTTP |
|--------|------|------|
| `ORD.VALIDATION.LOT_SIZE_INVALID` | 下单手数不符合 step | 400 |
| `ORD.PRECONDITION.MARKET_CLOSED` | 品种当前不可交易 | 422 |
| `ORD.CONFLICT.ORDER_ALREADY_FILLED` | 订单已成交，不可撤 | 409 |
| `LDG.CONFLICT.DOUBLE_ENTRY_BROKEN` | 借贷不平（不应发生，告警）| 500 |
| `FND.PRECONDITION.WITHDRAW_LIMIT_EXCEEDED` | 出金超日限额 | 422 |
| `FND.PRECONDITION.AML_REVIEW_REQUIRED` | 命中 AML 规则需人工 | 422 |
| `WLT.DEPENDENCY.NODE_UNREACHABLE` | 链上节点不可达 | 503 |
| `<identity-verification>.PRECONDITION.LEVEL_INSUFFICIENT` | <identity-verification> 等级不足以发起该操作 | 422 |
| `IDN.AUTH.TOKEN_EXPIRED` | token 过期 | 401 |
| `SYS.RATE_LIMIT.QUOTA_EXCEEDED` | 触发租户级限流 | 429 |

### 12.5 与服务详设的关系

- 各服务 `services/SXX-<name>/api.md` 中**必须**列出本服务用到的所有错误码
- 不允许出现未在本登记表 DOMAIN 列内的前缀
- `SYS.*` 由 api-gateway / 平台中间件统一抛出，业务服务不复用
- **BFF（mobile-bff / web-bff / admin-bff）不分配独立 DOMAIN**：BFF 不持业务规则，业务错误必须由权威 BC 抛出后透传；BFF 自身仅产生 `SYS.*`（聚合超时 / 网关错误）或透传下游 `IDN.* / FND.* / <identity-verification>.*` 等
