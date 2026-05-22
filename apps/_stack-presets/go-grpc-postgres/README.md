<!-- REFERENCE ONLY: sanitized sample, not for production -->
# go-grpc-postgres

后端：Go 1.22+
RPC：gRPC + buf
ORM：sqlc / pgx (raw)
测试：std testing + testify
可观测：OpenTelemetry SDK

## 何时选择

- 高并发、低延迟后端
- 大量内部微服务间通信（gRPC）
- 容器/资源效率优先

## 何时不选

- 业务对象关系复杂（ORM 弱）
- 团队 Go 经验不足
