<!-- REFERENCE ONLY: sanitized sample, not for production -->
# node-ts-postgres

后端语言：Node.js + TypeScript
框架候选：Fastify（推荐） / NestJS / Express
ORM：Prisma / Drizzle
测试：Vitest + Supertest
构建：tsx / esbuild

## 何时选择

- 团队主语言 JavaScript/TypeScript
- 中小型服务，需要快速迭代
- 已有大量 npm 生态依赖

## 何时不选

- CPU 密集（→ Go / Rust）
- 强类型 + 长生命周期 JVM 生态（→ Kotlin）

## 必须配合的 ADR

- ADR：选 ORM
- ADR：选 logger 与可观测栈
