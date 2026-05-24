<!-- 删除此模板说明文本，按结构填写 -->

## 概述

<一句话说明本 PR 做了什么 / 为什么>

## 关联

- Issue: #
- ADR: docs/adr/ADR-XXXX-*.md（如适用）
- 受影响 bctx: <bctx-name>

## 变更类型

- [ ] feat（新功能）
- [ ] fix（缺陷修复）
- [ ] refactor（重构 · 无行为变化）
- [ ] docs（文档）
- [ ] chore（构建 / 工具链）
- [ ] breaking（破坏性 · 必须有 ADR）

## 契约影响（D28）

- [ ] 修改了 `contracts/<bctx>/` 下的 schema → 已 bump 版本 / 兼容性已确认
- [ ] 跨 bctx 调用 → 已在 `apps/<svc>/internal/acl/` 加翻译层
- [ ] 修改了 `contracts/_common/` → 已有 ADR 通过

## 检查清单

- [ ] CI 全绿
- [ ] 新增 / 修改契约：已更新 `docs/services/<svc>/api.md`
- [ ] 新增告警：已写 runbook 并填 `runbook_url`
- [ ] 已运行本地校验（`make lint test`）
- [ ] CODEOWNERS 团队已 review
