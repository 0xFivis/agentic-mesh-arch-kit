<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-02 附录：错误码命名空间登记表

> 平台错误码格式：`<DOMAIN>.<CATEGORY>.<REASON>` 三段式，全大写点分。
> 详见 [STD-02 §4 错误响应](./README.md#4-错误响应)。

## 1. DOMAIN 登记表（一服务一域，已登记）

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

## 2. CATEGORY 标准枚举（跨域统一）

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

## 3. REASON 命名约定

- 单数名词或动名短语，全大写下划线
- 例：`INSUFFICIENT_BALANCE` / `<identity-verification>_NOT_APPROVED` / `ORDER_ALREADY_FILLED` / `SYMBOL_HALTED`
- 不在 `code` 中暴露内部实现细节（schema 名 / 内部字段名）

## 4. 完整码示例

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

## 5. 与服务详设的关系

- 各服务 `services/SXX-<name>/api.md` 中**必须**列出本服务用到的所有错误码
- 不允许出现未在本登记表 DOMAIN 列内的前缀
- `SYS.*` 由 api-gateway / 平台中间件统一抛出，业务服务不复用
- **BFF（mobile-bff / web-bff / admin-bff）不分配独立 DOMAIN**：BFF 不持业务规则，业务错误必须由权威 BC 抛出后透传；BFF 自身仅产生 `SYS.*`（聚合超时 / 网关错误）或透传下游 `IDN.* / FND.* / <identity-verification>.*` 等
