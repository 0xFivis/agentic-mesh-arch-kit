<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-03 — 数据

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft (MVP) | 架构组 + 平台组 | 0.1 | 2026-05-10 |

## 1. 主键与标识

- 业务实体主键 **MUST** 用 ULID（26 字符，DECIMAL 排序友好），存为 `CHAR(26)`
- **MUST NOT** 用自增 BIGINT 作为业务主键（仅可作内部物理 ID）
- 外键列名 = `<entity>_id`，例：`trading_account_id CHAR(26) NOT NULL`

> “表示运营主体归属”的列名与是否必选不在本 STD 决策，见 [ADR-0006 §2.6](../../tech-docs/adr/ADR-0006-multi-tenant-isolation.md)。

## 2. 命名约定

| 对象 | 规则 | 例 |
|------|------|-----|
| 表名 | snake_case 单数 | `trading_account` |
| 列名 | snake_case | `created_at` |
| 索引 | `idx_<table>_<cols>` | `idx_order_account_status` |
| 唯一索引 | `uq_<table>_<cols>` | `uq_user_email` |
| 外键 | `fk_<table>_<ref>` | `fk_order_account` |
| Schema | 一服务一 schema：`<service_short>` | `trading_ledger` |

## 3. 时间字段（强制）

- **MUST** 用 `TIMESTAMP WITH TIME ZONE`（PostgreSQL `TIMESTAMPTZ`），存 UTC
- 标准列：
  - `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
  - `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`（trigger 自动维护）
  - 业务时间另起：`occurred_at`、`settled_at` 等
- 业务日：`business_date DATE NOT NULL`（UTC 日界，见 ADR-0008）
- **MUST NOT** 用 `TIMESTAMP WITHOUT TIME ZONE` 或 epoch int

## 4. 金额与精度（强制）

- 所有金额 **MUST** 用 `DECIMAL(28,8)`（28 位总长，8 位小数）
- 列名 **MUST** 包含币种或显式标注：`amount_usd`、`amount` + `currency CHAR(3)`
- **MUST NOT** 用 `FLOAT` / `DOUBLE` / `NUMERIC` 不带精度
- 价格字段同精度 `DECIMAL(28,8)`
- 加密币精度按链最大支持位数（BTC 8、ETH 18）—— 链上原始单位用 `DECIMAL(38,0)` (satoshi/wei)

## 5. 枚举

- 数据库层 **MUST** 用 `VARCHAR(32)` + CHECK 约束，**MUST NOT** 用原生 ENUM 类型（演化不友好）
- 应用层 **MUST** 容忍未知值（forward compatibility）
- 枚举值大写下划线：`PENDING_APPROVAL`、`SETTLED`

## 6. 软删除 vs 硬删除

| 场景 | 策略 |
|------|------|
| 资金 / 交易 / 账本类 | **MUST NOT** 删除，仅标记状态 |
| 用户 PII | 合规期内软删除（`deleted_at`），到期硬删除 |
| 缓存 / 临时数据 | 硬删除 |

## 7. PII 与敏感数据

| 类别 | 示例 | 存储要求 |
|------|------|---------|
| **L1 公开** | 国家代码、币种 | 明文 |
| **L2 内部** | 用户名、邮箱（hash 索引）| 明文 + 列加密可选 |
| **L3 敏感** | 真实姓名、地址、电话 | **MUST** 列加密 (AES-256-GCM)，密钥来自 KMS |
| **L4 高度敏感** | 身份证号、银行卡、护照 | **MUST** 列加密 + 字段级访问审计；查询 **MUST** 走专用接口 |
| **L5 凭据** | 密码 hash、私钥、API secret | **MUST** 不入业务库；密码用 Argon2id；私钥进 HSM |

详见 [STD-05](../STD-05-security/)。

## 8. 数据保留与归档

| 数据类型 | 在线保留 | 归档保留 |
|---------|---------|---------|
| 交易/订单/账本 | 7 年 | 监管要求期满 |
| 资金流水 | 7 年 | 监管要求期满 |
| 用户 <identity-verification> 资料 | 用户存活期 + 5 年 | 销户后按地区监管 |
| 应用日志 | 30 天 | 1 年（冷存）|
| 审计日志 | 在线 90 天 | 7 年（WORM）|
| <market-data> tick | 7 天 | 30 天聚合 |

## 9. 多租户 / 多主体隔离

- 模式选型（Silo / Bridge / Pool）与主体归属列命名、必选性均在 [ADR-0006](../../tech-docs/adr/ADR-0006-multi-tenant-isolation.md)。
- Bridge / Pool 模式下需含主体归属列的表，**MUST** 使用行级安全 (RLS) 路由
- **MUST NOT** 跨主体 JOIN（数据反洗 / 监管隔离）

## 10. Migration

- **MUST** 用版本化迁移工具（Flyway / Liquibase / golang-migrate）
- **MUST NOT** 在生产手工执行 DDL
- 破坏性变更走"扩展 - 迁移 - 收缩"三步：先双写 → 切流 → 删旧列
