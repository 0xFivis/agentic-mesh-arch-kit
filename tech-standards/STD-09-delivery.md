<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-09 — 任务交付标准（DoR / DoD）

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 架构组 + Tech Lead | 0.1 | 2026-05-12 |

> **定位**：定义"一个 Issue 何时可以进 Sprint（DoR）"与"何时可以关单（DoD）"的**唯一权威标准**。
> **本仓只定义检查项与引用规则；具体业务/技术内容来源于其他 STD 与产品需求文档。**

## 目录

- §1 与其他 STD / 文档的关系
- §2 强制等级
- §3 与 team-operating-model 的边界
- §4 演进
- §5 **附录 A：Definition of Ready (DoR)**
- §6 **附录 B：Definition of Done (DoD)**
- §7 **附录 C：Issue 模板**
- §8 **附录 D：TDD 模板**

## 1. 与其他 STD / 文档的关系

DoD 不重复定义任何技术红线，而是**引用**：

| DoD 类目 | 来源 |
|----------|------|
| 编码规范 | [STD-01](./STD-01-coding.md) |
| API 契约 | [STD-02](./STD-02-api.md) + 服务详设契约文件 |
| 数据规范 | [STD-03](./STD-03-data.md) |
| 事件规范 | [STD-04](./STD-04-events.md) |
| 安全合规 | [STD-05](./STD-05-security.md) |
| 可观测性 | [STD-06](./STD-06-observability.md) |
| 测试覆盖 | [STD-07](./STD-07-testing.md) |
| 部署运维 | [STD-08](./STD-08-deployment.md) |
| 架构契约 | `tech-docs/services/<svc>/` 详设产物 |
| 业务验收 | 产品需求文档对应章节（由 Tech Intake 在 Issue 中显式引用） |

## 2. 强制等级

- DoR / DoD 通用清单中的项目，**默认 MUST**
- 个别项目对 Level B / Level C 任务可降级为 SHOULD（在清单内显式标注）
- 任何裁剪需在 Issue 描述中说明，并由 Tech Lead Approve

## 3. 与 team-operating-model 的边界

- **本仓（STD-09）**：DoR/DoD 的字段定义 + 检查规则 + 模板（被项目流转直接引用）
- **team-operating-model**：协作侧补充说明（角色职责、评审 SLA、退回流程），**不重复定义** DoR/DoD 内容

## 4. 演进

- 任何对 DoR/DoD 字段的增删，需走 ADR（影响所有团队）
- 模板调整（措辞 / 顺序 / 示例）由 Owner 直接更新即可

---

## 5. 附录 A：Definition of Ready (DoR)

> 一个 Issue 进入 Sprint 前，**MUST** 满足以下全部条件。任意一项不满足 → Issue 退回 Backlog，不允许排期。

### 5.1 DoR 通用清单

| # | 检查项 | 来源 / 证据 | 检查方 |
|---|--------|-------------|--------|
| 1 | **业务意图明确**：本任务要解决的业务问题、相关角色、期望结果在 Issue 描述中清楚陈述，并附产品方提供的需求依据链接 | 产品方提供的需求依据（链接由 Tech Intake 维护，**不绑定具体目录或文档结构**） | 产品 |
| 2 | **技术契约就绪**：本任务涉及的接口 / 事件 / 数据契约已经在服务详设中存在（已有服务）或在本任务前置 Issue 中产出（新服务） | `tech-docs/services/<svc>/` | 服务 Owner |
| 3 | **依赖闭合**：所有前置 Issue 已 `Done`，或可与本任务并行（依赖关系图无循环） | Issue 依赖字段 | Tech Lead |
| 4 | **工程环境就绪**：脚手架可用、本地能跑起、CI 流水线模板已套上、测试夹具/Mock 就位 | [STD-08](./STD-08-deployment.md) + 服务 Runbook | SRE / 服务 Owner |
| 5 | **粒度合规**：执行人初估 ≤ 3 人日；超出必须先拆分 | Issue 估时字段 | 执行人 + Tech Lead |

### 5.2 引用规则

- DoR 第 1 项的"需求依据链接"**仅以文字描述形式存在**——不在本文档中固定任何路径、目录或章节命名（产品文档形态可能演进）
- 如果某 Issue 的需求依据尚不存在或仍在修订中，DoR 第 1 项不通过
- DoR 第 2 项的契约引用 **MUST** 是文件 + 行级或锚点，不接受"参考服务详设"这类模糊表述

### 5.3 不在 DoR 内的事项

下列内容属于 DoD 范畴，**不**作为 DoR 检查项：

- 测试覆盖率
- Code Review
- 部署灰度
- 文档更新

DoR 关注"能不能开工"，DoD 关注"能不能关单"。两者互不重叠。

### 5.4 退回机制

- DoR 不通过的 Issue → 状态置为 `Backlog`，由 Tech Lead 在 Issue 中说明缺失项
- 同一 Issue 连续 2 次 DoR 不通过 → 升级到架构组评审，决定是否拆分或暂缓

### 5.5 裁剪

- Level C（小改动 / 无契约变更 / 无数据变更）任务可裁剪检查项 #2，但 **MUST** 在 Issue 中显式标注 `DoR-skip: 2 (Level C)`
- 其他裁剪需 Tech Lead Approve

---

## 6. 附录 B：Definition of Done (DoD)

> 一个 Issue 标记为 `Done` 前，**MUST** 满足以下全部条件。任意一项不满足 → Issue 退回 `In Progress`。

### 6.1 DoD 来源矩阵（核心）

DoD **不重复定义**任何技术或业务红线，而是引用既有来源：

| 类目 | 检查项 | 来源（MUST 在 Issue 中实例化引用） | 检查方 |
|------|--------|-----------------------------------|--------|
| 业务 | 业务验收点全部通过 | 产品方提供的需求依据（具体文档形态以当时项目约定为准；本文档**不绑定**任何路径或章节命名） | 产品 + 测试 |
| 契约 | API / 事件 / 数据契约符合 | `tech-docs/services/<svc>/` 中的 OpenAPI / Schema / 数据模型 | 架构 + 消费方 |
| 决策 | 引用的 ADR / STD 已 `Accepted` / 已发布 | ADR 索引 + STD 版本号 | 评审人 |
| 代码 | 编码规范 + Code Review Approve（≥2 人） | [STD-01](./STD-01-coding.md) | 评审人 |
| 测试 | 单元覆盖 ≥ 80% + 契约测试 + 必要的集成测试 | [STD-07](./STD-07-testing.md) | CI + 测试 |
| 安全 | 漏洞扫描 / 权限 / 敏感数据处理符合 | [STD-05](./STD-05-security.md) | CI + 安全组 |
| 数据 | 迁移脚本 + 回滚脚本 + 数据兼容性验证 | [STD-03](./STD-03-data.md) | DBA / 服务 Owner |
| 事件 | 事件 Schema 兼容性、幂等键、死信处理就绪 | [STD-04](./STD-04-events.md) | 服务 Owner + 消费方 |
| 观测 | 日志 / 指标 / 告警三件套上线 | [STD-06](./STD-06-observability.md) | SRE |
| 部署 | CI/CD 通过 + 灰度策略已定 | [STD-08](./STD-08-deployment.md) | SRE |
| 文档 | TDD / API 文档 / Runbook / Changelog 已更新 | 服务详设模板 | 服务 Owner |

### 6.2 引用规则

1. Issue 描述 **MUST** 显式列出本任务对应的来源链接（业务依据、契约文件路径、ADR 编号、STD 章节）
2. **不允许**写"参照通用标准"或"详见相关文档"——必须实例化到具体来源
3. **业务验收口径仅以产品方提供的需求依据为准**——开发方不得在 Issue / TDD / 代码注释中私自补充或修改业务规则
4. 任何来源链接失效（404 / 路径变更）→ DoD 不通过，需先修复链接

### 6.3 关于业务来源的稳定性

- 产品需求文档的载体形态（目录结构、文件命名、章节层级）在项目早期可能调整
- 因此本文档**仅以"产品方提供的需求依据"这一文字描述**指代该来源
- 具体路径与锚点由 Tech Intake 阶段在 Issue 中按当时实际形态填入
- **不在 STD-09 内固化任何 PRD 路径或章节命名**

### 6.4 不在 DoD 内的事项

下列属于运行期 / 上线后关注，**不**作为 DoD 检查项：

- 业务上线后实际指标
- 用户反馈
- 二期需求

### 6.5 退回机制

- DoD 不通过 → Issue 退回 `In Progress`，由检查方在 Issue 中标注未通过项
- 同一 Issue 连续 3 次 DoD 不通过 → 升级到 Tech Lead 评审，决定是否拆分或调整范围

### 6.6 裁剪

- Level B / Level C 任务对部分类目可降级为 SHOULD，规则详见各 STD 内的裁剪条款
- 任何裁剪 **MUST** 在 Issue 中显式标注 `DoD-skip: <类目> (<原因>)`，并由 Tech Lead Approve

---

## 7. 附录 C：Issue 模板（实例化 DoR / DoD）

> 所有研发 Issue **MUST** 使用本模板。可在仓库的 Issue Template 中固化。

```markdown
## 1. 任务概述
（一句话：要做什么，解决什么问题）

## 2. 引用来源（DoR / DoD 实例化）
- **业务依据**：<产品方提供的需求文档链接 + 章节描述；形式以当时项目约定为准>
- **接口契约**：<例如 tech-docs/services/<service>/api.md#L120-L180>
- **依赖 ADR**：<例如 ADR-0042>
- **依赖 STD**：<例如 STD-04 §3.2>
- **前置 Issue**：<#123 #124>

## 3. DoR 自检（拉单前）
- [ ] 上述引用全部可访问
- [ ] 前置 Issue 已 Done 或可并行
- [ ] 工程环境就绪（本地能跑、CI 模板套上、夹具就位）
- [ ] 估时：< X 人日（≤ 3）
- [ ] 粒度合规（如 > 3 人日，已拆分为子 Issue：#xxx #xxx）

## 4. 实施要点
（关键设计点、与其他 Issue 的协作点、风险）

## 5. DoD 自检（关单前）
- [ ] 业务验收点全部通过
- [ ] 契约测试通过
- [ ] 单元覆盖 ≥ 80%
- [ ] CI 全绿（含安全扫描）
- [ ] PR 已 Approve（≥ 2 人）
- [ ] 数据迁移 / 回滚脚本就绪（如适用）
- [ ] 观测三件套（日志 / 指标 / 告警）上线
- [ ] 灰度策略已定
- [ ] 文档 / Runbook / Changelog 更新

## 6. 裁剪声明（如适用）
- DoR-skip: <项> (<原因>)
- DoD-skip: <类目> (<原因>)
- Approver: @<tech-lead>
```

### 7.1 使用约束

- 第 2 节"引用来源"中的业务依据**仅以文字描述形式填写**，不要在模板中固定任何 PRD 路径或目录前缀
- 第 5 节 DoD 自检项的标准定义在本文 §6，模板只做勾选实例

---

## 8. 附录 D：TDD 模板（技术设计文档）

> Level A / Level B 任务 **MUST** 在编码前提交 TDD 并通过 G1 Design Review。Level C 可省略。

```markdown
# TDD — <任务标题>

## 0. 元信息
- 关联 Issue：#xxx
- 作者：@xxx
- 评审人：@xxx @xxx
- 状态：Draft / Review / Accepted

## 1. 背景与目标
（业务背景一句话；技术目标 2-3 句）

## 2. 引用来源
- 业务依据：<产品方提供的需求文档链接 + 章节描述>
- 上游契约：<服务详设文件 / 锚点>
- 依赖 ADR：<编号列表>
- 依赖 STD：<编号 + 章节>

## 3. 设计方案
- 模块划分
- 数据模型变更（含迁移与回滚）
- 接口/事件契约变更
- 状态机 / 关键时序

## 4. 备选方案与取舍
（≥ 1 个被否决的方案，说明为什么不选）

## 5. 影响分析
- 兼容性（消费方、客户端）
- 性能 / 容量
- 安全 / 合规
- 可观测点新增

## 6. 测试策略
- 单元 / 契约 / 集成 / E2E 范围
- 灰度方案

## 7. DoR / DoD 引用
- DoR：见 Issue #xxx 第 3 节
- DoD：见 Issue #xxx 第 5 节
- 本 TDD **不重复定义** DoR/DoD 内容；标准定义在 [STD-09](./STD-09-delivery.md)
```

### 8.1 使用约束

- 第 2 节业务依据**仅以文字描述形式填写**，不绑定任何固定 PRD 路径
- 第 7 节不允许在 TDD 中重新定义 DoR/DoD 字段，必须引用 STD-09
