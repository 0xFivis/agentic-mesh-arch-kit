<!-- REFERENCE ONLY: sanitized sample, not for production -->
# Definition of Ready (DoR)

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 架构组 + Tech Lead | 0.1 | 2026-05-12 |

> 一个 Issue 进入 Sprint 前，**MUST** 满足以下全部条件。任意一项不满足 → Issue 退回 Backlog，不允许排期。

## 1. DoR 通用清单

| # | 检查项 | 来源 / 证据 | 检查方 |
|---|--------|-------------|--------|
| 1 | **业务意图明确**：本任务要解决的业务问题、相关角色、期望结果在 Issue 描述中清楚陈述，并附产品方提供的需求依据链接 | 产品方提供的需求依据（链接由 Tech Intake 维护，**不绑定具体目录或文档结构**） | 产品 |
| 2 | **技术契约就绪**：本任务涉及的接口 / 事件 / 数据契约已经在服务详设中存在（已有服务）或在本任务前置 Issue 中产出（新服务） | `tech-docs/services/<svc>/` | 服务 Owner |
| 3 | **依赖闭合**：所有前置 Issue 已 `Done`，或可与本任务并行（依赖关系图无循环） | Issue 依赖字段 | Tech Lead |
| 4 | **工程环境就绪**：脚手架可用、本地能跑起、CI 流水线模板已套上、测试夹具/Mock 就位 | [STD-08](../STD-08-deployment/) + 服务 Runbook | SRE / 服务 Owner |
| 5 | **粒度合规**：执行人初估 ≤ 3 人日；超出必须先拆分 | Issue 估时字段 | 执行人 + Tech Lead |

## 2. 引用规则

- DoR 第 1 项的"需求依据链接"**仅以文字描述形式存在**——不在本文档中固定任何路径、目录或章节命名（产品文档形态可能演进）
- 如果某 Issue 的需求依据尚不存在或仍在修订中，DoR 第 1 项不通过
- DoR 第 2 项的契约引用 **MUST** 是文件 + 行级或锚点，不接受"参考服务详设"这类模糊表述

## 3. 不在 DoR 内的事项

下列内容属于 DoD 范畴，**不**作为 DoR 检查项：

- 测试覆盖率
- Code Review
- 部署灰度
- 文档更新

DoR 关注"能不能开工"，DoD 关注"能不能关单"。两者互不重叠。

## 4. 退回机制

- DoR 不通过的 Issue → 状态置为 `Backlog`，由 Tech Lead 在 Issue 中说明缺失项
- 同一 Issue 连续 2 次 DoR 不通过 → 升级到架构组评审，决定是否拆分或暂缓

## 5. 裁剪

- Level C（小改动 / 无契约变更 / 无数据变更）任务可裁剪检查项 #2，但 **MUST** 在 Issue 中显式标注 `DoR-skip: 2 (Level C)`
- 其他裁剪需 Tech Lead Approve
