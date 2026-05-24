# docs/services/

> 单个服务的"文件矩阵"（3 强制 + 4 按需 + 1 自动）。每个服务在此有一个目录，目录名 = 服务名。
> 治理细则与文件矩阵定义见 [`../architecture/00_governance.md §5`](../architecture/00_governance.md)。

## 目录结构

```
docs/services/
├── README.md                  ← 本文件
├── _registry.yaml             ← 战术 SSOT · 全部服务清单（name/bctx/role/owner/repo/runtime/slo/contracts）
├── _template/                 ← 模板骨架（new-service.sh 按 --type 拷贝子集）
│   ├── README.md              VIEW · 服务一句话定位 + 入口 + 联系人（强制）
│   ├── runbook.md             SSOT · 部署 / 监控 / 故障处置（强制）
│   ├── non-functional.md      VIEW · SLO / 容量 / 安全（引 STD-05/06/07）（强制）
│   ├── api.md                 VIEW · 对外 HTTP 接口（引 contracts/<bctx>/openapi/<svc>/）（按需：api/gateway）
│   ├── events.md              VIEW · 产出与消费事件（引 contracts/<bctx>/asyncapi/）（按需：api/worker/saga）
│   ├── saga.md                SSOT · 跨服务长流程（按需：saga）
│   └── state-machine.md       SSOT · 核心状态机（按需：worker/saga）
└── <svc>/                     真实服务（由 new-service.sh 创建）
    ├── 上述 _template 子集（按 --type 选）
    └── _data-index.md         AUTO · 由 scripts/build-data-index.py 扫 apps/<svc>/migrations/*.sql 生成（禁手改）
```

## 文件矩阵（new-service.sh --type 决定）

| 类型 | README | runbook | non-functional | api | events | saga | state-machine | _data-index |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **api** | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | AUTO |
| **worker** | ✅ | ✅ | ✅ | — | ✅ | — | ✅ | AUTO |
| **saga** | ✅ | ✅ | ✅ | — | ✅ | ✅ | ✅ | AUTO |
| **gateway** | ✅ | ✅ | ✅ | ✅ | — | — | — | AUTO |

**不再生成**（D17 / W11 决议）：

- ❌ `data-model.md` —— DDL 入 `apps/<svc>/migrations/*.sql`（L3 SSOT），`_data-index.md` 是其只读视图
- ❌ `open-questions.md` —— 用 Issue tracker 记录

## bctx 归属（D28）

每个服务必属于 `_context-map.yaml` 中已登记的某个 bctx。`README.md` 头部 frontmatter 含：

```yaml
---
bctx: <bounded-context>
owner: <team-or-person>
lifecycle: alpha | beta | ga | deprecated
---
```

未声明 bctx 或 bctx 未在 context-map 登记 → `new-service.sh` 拒绝创建，CI 校验失败。

## ROLE 徽章

每个 `.md` 首行注释之后必须含 `<!-- ROLE: ... -->`（SSOT / VIEW / SPEC / AUTO），定义与红线见 [`../architecture/00_governance.md §1`](../architecture/00_governance.md)。模板已预填，作者填占位即可。

## _registry.yaml 写入

`new-service.sh` 自动追加一行到 `_registry.yaml`（字段以 `_registry.yaml.tmpl` 为权威；service-level `lifecycle` 只出现在各服务 `README.md` frontmatter）：

```yaml
services:
  - name: <svc>
    bctx: <bounded-context>
    role: <api|worker|saga|gateway>
    owner: <team>
    repo: <git-url-or-path>
    runtime: <lang>
    slo:
      availability: 99.9
      latency_p95_ms: 200
    contracts:
      provides:
        - contracts/<bounded-context>/openapi/<svc>/v1/api.yaml
      consumes:
        - contracts/<other-bctx>/asyncapi/<event>.v1.yaml
```
