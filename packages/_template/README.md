<!-- REFERENCE ONLY: sanitized sample, not for production -->
# packages/_template/

> 共享库（package）模板。

## 适用范围

- ACL（anti-corruption-layer）：`packages/acl-<external-system>/`
- 通用工具：`packages/utils-<name>/`（**禁止**承载业务逻辑）
- 客户端 SDK：`packages/client-<bctx>/`

## 红线

- ❌ 包内不得包含跨 BC 共享的领域模型
- ❌ 包内不得直连任何 BC 的数据库
- ✅ 必须有独立 README + CHANGELOG
