<!-- REFERENCE ONLY: sanitized sample, not for production -->
# TDD 模板（技术设计文档）

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 架构组 + Tech Lead | 0.1 | 2026-05-12 |

> Level A / Level B 任务 **MUST** 在编码前提交 TDD 并通过 G1 Design Review。Level C 可省略。

---

## 模板正文

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
- 本 TDD **不重复定义** DoR/DoD 内容；标准定义在 [STD-09](./)
```

---

## 使用约束

- 第 2 节业务依据**仅以文字描述形式填写**，不绑定任何固定 PRD 路径
- 第 7 节不允许在 TDD 中重新定义 DoR/DoD 字段，必须引用 STD-09
