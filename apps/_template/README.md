<!-- REFERENCE ONLY: sanitized sample, not for production -->
# apps/_template/

> service skeleton 占位。scripts/new-service.sh 会复制此目录到 `apps/svc-<NN>-<bctx>-<role>/`。

## 必须的子目录

- `src/` — 源码
- `tests/` — 测试（unit/integration），由 stack-preset 注入
- `migrations/` — 数据库迁移脚本（由 `data-model.md` 索引，命名规范见 STD-03）
- `internal/acl/` — **反腐败层**（D28 强制）：跨 bctx 调用时的翻译层；按上游 bctx 分子目录 `internal/acl/<upstream-bctx>/`
- `docs/` — 服务级 README + runbook 链接（与 `docs/services/<svc>/` 双向引用）
- `Dockerfile` — 容器构建
- `Makefile` — 标准 target（test/lint/build/run）
- `.env.example` — 配置示例（不含真实凭证）

> 实际内容由 `apps/_stack-presets/<preset>/` 注入。
