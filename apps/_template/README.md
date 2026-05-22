<!-- REFERENCE ONLY: sanitized sample, not for production -->
# apps/_template/

> service skeleton 占位。scripts/new-service.sh 会复制此目录到 `apps/svc-<NN>-<bctx>-<role>/`。

## 必须的子目录

- `src/` — 源码
- `tests/` — 测试（unit/integration）
- `docs/` — 服务级 README + runbook 链接
- `Dockerfile` — 容器构建
- `Makefile` — 标准 target（test/lint/build/run）
- `.env.example` — 配置示例（不含真实凭证）

> 实际内容由 `apps/_stack-presets/<preset>/` 注入。
