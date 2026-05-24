<!-- REFERENCE ONLY: sanitized template, fill before use -->
# testing/ · 跨服务测试 5 分

> 单服务 unit test 归 `apps/<service>/tests/`（不在此）；本目录承载**跨服务 / 跨契约 / 全链路**测试。

## 5 分边界

| 子目录 | 职责 | 触发 | 关联 STD |
|---|---|---|---|
| `contract/` | 消费者-提供方契约测试（Pact / Spring Cloud Contract）| 契约变更 PR | STD-07 测试 |
| `integration/` | 多服务集成（实际起 docker-compose / k8s namespace）| nightly / release | STD-07 |
| `e2e/` | 端到端业务流（含 UI / 移动端 / API 链路）| pre-release | STD-07 |
| `load/` | 性能 / 压测（k6 / locust / Gatling 脚本）| 大版本 / 容量评估 | STD-07 / STD-08 |
| `fixtures/` | 跨多类测试共享的样本数据 / mock server / seed | 引用方按需 | — |

## 与 apps/<svc>/tests/ 的边界

- `apps/<svc>/tests/unit/` · `tests/integration/`（**单服务内部** integration · 不跨进程）→ 归服务自身
- 本目录 `integration/` → **跨服务** integration（多容器协作）

判断口诀：**跨进程 / 跨契约 → testing/**；**单进程内 → apps/<svc>/tests/**。

## 与 ops/ 的边界

- `testing/` = 变更前质量门（CI 阻塞）
- `ops/` = 运行期可观测（生产）

## 红线

- 契约变更必须先过 `contract/` 测试再合（CI 强制）
- `load/` 脚本必须可重放（参数化，禁硬编码生产 endpoint）
- `fixtures/` 禁含真实用户数据（脱敏 checklist 通过）
