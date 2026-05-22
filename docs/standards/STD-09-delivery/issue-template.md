<!-- REFERENCE ONLY: sanitized sample, not for production -->
# Issue 模板（实例化 DoR / DoD）

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 架构组 + Tech Lead | 0.1 | 2026-05-12 |

> 所有研发 Issue **MUST** 使用本模板。可在仓库的 Issue Template 中固化。

---

## 模板正文

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

---

## 使用约束

- 第 2 节"引用来源"中的业务依据**仅以文字描述形式填写**，不要在模板中固定任何 PRD 路径或目录前缀
- 第 5 节 DoD 自检项的标准定义在 [definition-of-done.md](definition-of-done.md)，本模板只做勾选实例
