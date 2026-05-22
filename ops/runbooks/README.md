<!-- REFERENCE ONLY: sanitized sample, not for production -->
# ops/runbooks/

> SRE 运行手册（runbook）。

约定：每个 P0/P1 告警必须对应一个 runbook：`<alert-name>.md`，包含：
1. 现象
2. 影响面（哪些 BC / 用户）
3. 诊断步骤（命令、查询）
4. 缓解措施（短期）
5. 根治方案（长期）
6. 回滚步骤

模板见 `_template.md`（首次新增时建立）。
