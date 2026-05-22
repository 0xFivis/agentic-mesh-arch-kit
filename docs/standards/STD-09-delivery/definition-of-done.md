<!-- REFERENCE ONLY: sanitized sample, not for production -->
# Definition of Done (DoD)

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 架构组 + Tech Lead | 0.1 | 2026-05-12 |

> 一个 Issue 标记为 `Done` 前，**MUST** 满足以下全部条件。任意一项不满足 → Issue 退回 `In Progress`。

## 1. DoD 来源矩阵（核心）

DoD **不重复定义**任何技术或业务红线，而是引用既有来源：

| 类目 | 检查项 | 来源（MUST 在 Issue 中实例化引用） | 检查方 |
|------|--------|-----------------------------------|--------|
| 业务 | 业务验收点全部通过 | 产品方提供的需求依据（具体文档形态以当时项目约定为准；本文档**不绑定**任何路径或章节命名） | 产品 + 测试 |
| 契约 | API / 事件 / 数据契约符合 | `tech-docs/services/<svc>/` 中的 OpenAPI / Schema / 数据模型 | 架构 + 消费方 |
| 决策 | 引用的 ADR / STD 已 `Accepted` / 已发布 | ADR 索引 + STD 版本号 | 评审人 |
| 代码 | 编码规范 + Code Review Approve（≥2 人） | [STD-01](../STD-01-coding/) | 评审人 |
| 测试 | 单元覆盖 ≥ 80% + 契约测试 + 必要的集成测试 | [STD-07](../STD-07-testing/) | CI + 测试 |
| 安全 | 漏洞扫描 / 权限 / 敏感数据处理符合 | [STD-05](../STD-05-security/) | CI + 安全组 |
| 数据 | 迁移脚本 + 回滚脚本 + 数据兼容性验证 | [STD-03](../STD-03-data/) | DBA / 服务 Owner |
| 事件 | 事件 Schema 兼容性、幂等键、死信处理就绪 | [STD-04](../STD-04-events/) | 服务 Owner + 消费方 |
| 观测 | 日志 / 指标 / 告警三件套上线 | [STD-06](../STD-06-observability/) | SRE |
| 部署 | CI/CD 通过 + 灰度策略已定 | [STD-08](../STD-08-deployment/) | SRE |
| 文档 | TDD / API 文档 / Runbook / Changelog 已更新 | 服务详设模板 | 服务 Owner |

## 2. 引用规则

1. Issue 描述 **MUST** 显式列出本任务对应的来源链接（业务依据、契约文件路径、ADR 编号、STD 章节）
2. **不允许**写"参照通用标准"或"详见相关文档"——必须实例化到具体来源
3. **业务验收口径仅以产品方提供的需求依据为准**——开发方不得在 Issue / TDD / 代码注释中私自补充或修改业务规则
4. 任何来源链接失效（404 / 路径变更）→ DoD 不通过，需先修复链接

## 3. 关于业务来源的稳定性

- 产品需求文档的载体形态（目录结构、文件命名、章节层级）在项目早期可能调整
- 因此本文档**仅以"产品方提供的需求依据"这一文字描述**指代该来源
- 具体路径与锚点由 Tech Intake 阶段在 Issue 中按当时实际形态填入
- **不在 STD-09 内固化任何 PRD 路径或章节命名**

## 4. 不在 DoD 内的事项

下列属于运行期 / 上线后关注，**不**作为 DoD 检查项：

- 业务上线后实际指标
- 用户反馈
- 二期需求

## 5. 退回机制

- DoD 不通过 → Issue 退回 `In Progress`，由检查方在 Issue 中标注未通过项
- 同一 Issue 连续 3 次 DoD 不通过 → 升级到 Tech Lead 评审，决定是否拆分或调整范围

## 6. 裁剪

- Level B / Level C 任务对部分类目可降级为 SHOULD，规则详见各 STD 内的裁剪条款
- 任何裁剪 **MUST** 在 Issue 中显式标注 `DoD-skip: <类目> (<原因>)`，并由 Tech Lead Approve
