# Tech Debt · agentic-mesh-arch-kit

> 仅记录本仓相关的技术债。AI-kit 侧债务见 `agentic-mesh-ai-kit/docs/TECH-DEBT.md`。
> 更新规则：完成项打 ✅ 并保留行；不再有效项移到 `## 已归档`。

最近更新：2026-05-24（Phase A–E 收尾后初版）

---

## P1 · 影响功能正确性

### AD-01 · W15 spectral 校验未启用
- **位置**：`scripts/check-contracts-drift.py`
- **现状**：只做路径存在 + 顶层 `openapi`/`asyncapi` 字段校验（PyYAML），未集成 `@stoplight/spectral-cli` 真·schema lint。
- **风险**：契约字段错位、breaking change 不会被拦截。
- **建议**：`.github/workflows/contracts-drift.yml` 加 `npx -y @stoplight/spectral-cli lint contracts/**/*.yaml`，并在脚本中作为可选 step（`--with-spectral`）。

### AD-02 · `apps/svc-*` parity 在编码起步期会全红
- **位置**：`scripts/check-contracts-sync.py` 的 `[D]` 检查
- **现状**：项目尚未编码，registry 中声明的 svc 都会触发 "apps/<svc>/ missing"。仅 `<...>` 占位被过滤。
- **建议**：增加 `--registry-only` 或 `--skip-parity` 开关；或允许 service 标记 `status: planned` 跳过 parity。

### AD-03 · W12 `build-data-index` fail/warn 语义需复核
- **位置**：`.github/workflows/build-data-index.yml`
- **现状**：governance §7 表述"漂移即 fail"，workflow 现含 `exit 0` 跳过分支，未确认真实漂移路径会 fail。
- **建议**：手动跑一次"模拟漂移"的 PR，确认 CI 真的红。

---

## P2 · 文档与契约一致性

### AD-04 · `_registry.yaml.tmpl` events 段 schema 未文档化
- **位置**：`docs/services/_registry.yaml.tmpl` L33–37 + `docs/architecture/00_governance.md §5`
- **现状**：events 示例含 `id/publisher/schema/subscribers`，但 governance §5 没有事件 schema 规范段落；W16 校验依赖这套未文档化的隐式约定。
- **建议**：在 governance §5 后增 §5.3 "events schema"，明确字段语义 + 命名规则（如 `<bctx>.<aggregate>.<verb>.v<N>`）。

### AD-05 · 3 个 governance hook 仍标 "待建"
- **位置**：`docs/architecture/00_governance.md §7`
- **未实现**：`role-badge lint`、`_data-index lint`（标 "内置" 但实际未实现）、`spec HOW lint`（属 ai-kit 范畴可不在此追）。
- **建议**：为 `role-badge lint` 写一个 `scripts/check-role-badges.py`，扫 `docs/services/**/*.md` + `tech-standards/**/*.md` 首行注释。

---

## P3 · 工程化 / 维护性

### AD-06 · PyYAML 是隐式依赖
- **位置**：`scripts/check-contracts-drift.py`、`scripts/check-contracts-sync.py`、`scripts/build-data-index.py`
- **现状**：本地手跑需先装 pyyaml；CI workflow 已 `pip install pyyaml` 兜底。
- **建议**：增 `scripts/requirements.txt` 或在 `scripts/README.md` 一行提示。

### AD-07 · `scripts/` 缺统一 README 与自测
- **位置**：`scripts/`（4 个脚本）
- **现状**：无 unit test，无 `--version` 或 self-check；schema 一旦改，脚本回归无防护。
- **建议**：补 `scripts/README.md`（每脚本一段：用途 / 触发 / 退出码）+ `scripts/tests/` 含最小 fixture。

---


## TD · 跨仓治理 / 流程 / 知识类技术债（明确推迟，避免遗忘）

> 状态：本轮 R2 系统审计沉淀；非阻塞当下“心智模型 + SOP+AI 流程清晰可落地”目标，**待心智模型/落地框架完成后**集中处理。
>
> 以下条目从 memory `decisions-log.md §E` 同步过来，选与 arch-kit 相关的 / 偶跨仓的；ai-kit 侧 TECH-DEBT 同样同步一份（两边都保留，便于任一仓独立阅读）。

| # | 债务 | 类别 | 触发条件 |
|---|------|------|---------|
| TD1 | 架构组角色定义（人数/SLA/选拔/oncall） | 治理 | team-operating-model 同步成熟时 |
| TD2 | 横切 R 监控节奏（频率/触发/输出 action）| 治理 | 第一次实跑 retro 后 |
| TD3 | 争议解决路径（作者 vs reviewer 不一致升级链）| 治理 | 首次出现实际争议 |
| TD4 | D20 签字授权矩阵细化（每个 Gate 的可授权条件枚举）| 治理 | 团队首次跑通完整 SOP 后 |
| TD5 | CI 链路总图（W12/W15/W16/lint/sync 触发顺序+失败处置）| 工具 | W12+W16 任一落地时 |
| TD6 | PR template / Issue template 化（回写③ checkbox / open-questions label）| 工具 | W17 reviewer-agent 落地前 |
| TD7 | gate-checklist 5 条具体内容核对（与 playbook cross-check）| 工具 | T4.1 首次实跑前 |
| TD8 | bctx 重组流程（服务跨 bctx 迁移 contracts/<bctx>/ 路径变更）| 流程 | 首次出现需求时 |
| TD9 | 服务下线/deprecated 流程 + `_registry.yaml` status 字段 | 流程 | 第一个服务下线时 |
| TD10 | 跨子仓落地 roadmap（ai-workflow/playbook/arch-kit/ai-kit/tech-standards 实施顺序）| 实施 | 心智模型定型后立即处理（最优先 TD）|
| TD11 | emergency hotfix lane 显式化（虽 D20 已通用授权机制覆盖，可能需单独 SOP 短路径）| 流程 | 首次紧急 fix 后 retro |
| TD12 | _data-index.md 自动化前的过渡期描述（W12 未上前如何看 schema 状态）| 工具 | W12 排期前 |
| TD13 | AI agent (Claude/Codex/Copilot/Cursor) 差异化使用指南 | 知识 | 第二个 agent 接入时 |
| TD14 | 新人 onboarding 路径（design-philosophy → SOP → playbook → inventory 阅读图）| 知识 | 第一个新人加入时 |
