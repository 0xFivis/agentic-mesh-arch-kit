<!-- REFERENCE ONLY: sanitized sample, not for production -->
# apps/_stack-presets/

> 4 套技术栈预设，scripts/scaffold.sh 通过 `--preset <name>` 选择。

| Preset | 后端 | 前端 | 数据库 | 适用场景 |
|--------|------|------|--------|---------|
| `node-ts-postgres` | Node.js + TypeScript (Fastify/NestJS) | React/Next.js | PostgreSQL | 通用 SaaS |
| `python-fastapi-postgres` | Python + FastAPI | React/Vite | PostgreSQL | 数据/AI 密集 |
| `go-grpc-postgres` | Go + gRPC | — | PostgreSQL | 高并发后端 |
| `kotlin-spring-postgres` | Kotlin + Spring Boot | — | PostgreSQL | 企业 / JVM 生态 |

每个 preset 在子目录提供：
- `service.template.yaml`：service skeleton 元信息
- `Dockerfile.tmpl`
- `Makefile.tmpl`
- `README.md`：preset 适用说明 + ADR 候选指引
