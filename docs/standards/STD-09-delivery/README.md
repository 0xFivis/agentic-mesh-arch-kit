<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-09 — 任务交付标准（DoR / DoD）

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 架构组 + Tech Lead | 0.1 | 2026-05-12 |

> **定位**：定义"一个 Issue 何时可以进 Sprint（DoR）"与"何时可以关单（DoD）"的**唯一权威标准**。
> **本仓只定义检查项与引用规则；具体业务/技术内容来源于其他 STD 与产品需求文档。**

## 文档清单

| 文档 | 内容 |
|------|------|
| [definition-of-ready.md](definition-of-ready.md) | DoR 通用清单 + 字段定义 + 检查方 |
| [definition-of-done.md](definition-of-done.md) | DoD 通用清单 + **来源矩阵** + 引用规则 |
| [issue-template.md](issue-template.md) | 单任务 Issue 模板（实例化 DoR/DoD） |
| [tdd-template.md](tdd-template.md) | TDD 模板（含 DoR/DoD 章节） |

## 与其他 STD / 文档的关系

DoD 不重复定义任何技术红线，而是**引用**：

| DoD 类目 | 来源 |
|----------|------|
| 编码规范 | [STD-01](../STD-01-coding/) |
| API 契约 | [STD-02](../STD-02-api/) + 服务详设契约文件 |
| 数据规范 | [STD-03](../STD-03-data/) |
| 事件规范 | [STD-04](../STD-04-events/) |
| 安全合规 | [STD-05](../STD-05-security/) |
| 可观测性 | [STD-06](../STD-06-observability/) |
| 测试覆盖 | [STD-07](../STD-07-testing/) |
| 部署运维 | [STD-08](../STD-08-deployment/) |
| 架构契约 | `tech-docs/services/<svc>/` 详设产物 |
| 业务验收 | 产品需求文档对应章节（由 Tech Intake 在 Issue 中显式引用） |

## 强制等级

- DoR / DoD 通用清单中的项目，**默认 MUST**
- 个别项目对 Level B / Level C 任务可降级为 SHOULD（在清单内显式标注）
- 任何裁剪需在 Issue 描述中说明，并由 Tech Lead Approve

## 与 team-operating-model 的边界

- **本仓（STD-09）**：DoR/DoD 的字段定义 + 检查规则 + 模板（被项目流转直接引用）
- **team-operating-model**：协作侧补充说明（角色职责、评审 SLA、退回流程），**不重复定义** DoR/DoD 内容

## 演进

- 任何对 DoR/DoD 字段的增删，需走 ADR（影响所有团队）
- 模板调整（措辞 / 顺序 / 示例）由 Owner 直接更新即可
