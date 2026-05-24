# docs/adr/

> Architecture Decision Records · Michael Nygard 5 段式。

## 何时写 ADR

- **结构性决策**：会被未来反复参照、推翻代价高的（数据库选型、消息模型、跨服务通信范式）
- **多方案权衡**：≥ 2 个候选，需要记录"为什么没选 X"
- **不**写 ADR：库 / 框架的版本升级、纯实现细节

## 命名

`ADR-NNNN-<title-in-kebab-case>.md`，NNNN 四位数字、单调递增、永不复用。
- `ADR-0001-record-architecture-decisions.md`
- `ADR-0002-choose-postgres-as-primary-store.md`

## 5 段式（不可省略）

1. **Status** — Proposed / Accepted / Deprecated / Superseded by ADR-XXXX
2. **Context** — 触发本决策的背景与约束
3. **Decision** — 我们决定做 X
4. **Consequences** — 正负后果（含技术债）
5. **Alternatives Considered** — ≥ 2 个候选 + 排除理由

## 生命周期

- **永不删除**：已 Accepted 的 ADR 若被推翻，将 Status 改 `Superseded by ADR-XXXX`，正文保留
- **Deprecated** 用于不再推荐但未被替换的决策

## 模板

见 `_template/ADR-NNNN-title.md.tmpl`。复制后改名 + 替换占位符。
