<!-- REFERENCE ONLY: sanitized sample, not for production -->
# docs/prd/

> 本目录承载产品需求文档（Product Requirements Documents）。

## 约定

- 文件名：`<area>/<feature-slug>.md`
- 每个 PRD 必须含三层（L1/L2/L3）：
  - L1：业务规则（不可变约束）
  - L2：交互规范（流程、状态、错误处理）
  - L3：验收标准（可测条款）
- 跨 BC 引用必须列出受影响 `_context-map.yaml` 节点
- 与 `tech-docs/` 单向：PRD 不反向引用技术文档

## 模板

参见 `docs/prd/_templates/prd-template.md`（若需要建立，请走 ADR 流程）。

## 与 skills 的接口

`skills/tech-intake/SKILL.md` 在 T1 阶段把 PRD 拆解为 spec.md，落 `specs/<feature-id>/spec.md`。
