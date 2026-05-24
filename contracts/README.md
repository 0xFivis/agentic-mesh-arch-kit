# contracts/

> 跨服务契约（HTTP / 异步事件 / gRPC）的**唯一可信源**。所有跨服务调用必须先在此声明，再实现。

## 目录结构（D28 · DDD bounded-context 一级）

```
contracts/
├── README.md                          ← 本文件
├── _common/                           ← 跨 bctx 真公共白名单（生产可直引）
│   ├── openapi/{error,pagination}.yaml
│   ├── asyncapi/envelope.yaml         CloudEvents 信封
│   └── proto/v1/{timestamp,money}.proto
├── _template/                         ← bctx 骨架（可复制 · 非生产数据）
│   └── <bounded-context>/
│       ├── README.md
│       ├── openapi/<svc>/v1/api.yaml
│       ├── asyncapi/v1/events.yaml
│       ├── proto/v1/<service>.proto
│       └── _shared/
└── <bounded-context>/                 ← 真实 bctx（由 scripts/new-service.sh 实例化）
    └── ... 同 _template 结构
```

## 三层共享约束

| 层 | 范围 | 允许内容 | 禁止内容 |
|---|---|---|---|
| `_common/` | 跨 bctx | envelope / error / pagination / 原生扩展（timestamp / money） | 任何业务概念（订单、账户、用户...） |
| `<bctx>/_shared/` | 单 bctx 内 | 此上下文自有的 Money / Address 等业务定义 | 跨 bctx 引用 |
| `<bctx>/{openapi,asyncapi,proto}/` | 服务级 | 该 bctx 内服务的对外契约 | 跨 bctx `$ref` / `import`（必须经 ACL） |

## 跨 bctx 引用红线（D28）

- **禁止**跨 bctx 直接 `$ref` / `import`：必须在调用方 `apps/<svc>/internal/acl/` 写翻译层
- **共享类型**仅限 `_common/` 白名单；新增白名单需 ADR
- 命名空间隔离 = schema 边界 = 团队边界（CODEOWNERS 锁）

## 新 bctx / 新服务的创建流程

1. 在 `docs/architecture/_context-map.yaml` 登记 bctx（无登记则 `new-service.sh` 拒绝）
2. 跑 `scripts/new-service.sh --bctx <X> --name <svc> --type <api|worker|saga>`
3. 脚本自动从 `_template/<bounded-context>/` 实例化 `<X>/` 骨架（占位符替换）
4. 填充 openapi/asyncapi/proto，按服务粒度补 README

## 校验

`retro-audit` skill 第 12 条（D28 三规则）：
- (a) bctx 作为 `contracts/<bctx>/` 一级目录
- (b) 跨 bctx 调用必经 ACL（`apps/<svc>/internal/acl/`）
- (c) 跨 bctx 共享类型仅落 `_common/` 白名单
