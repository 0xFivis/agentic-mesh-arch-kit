<!-- REFERENCE ONLY: sanitized sample, not for production -->
# STD-05 — 安全

| Status | Owner | Version | Last Updated |
|--------|-------|---------|--------------|
| Draft  | 安全组 + 架构组 | 0.1 | 2026-05-10 |

> **状态**：骨架占位。Phase C 启动 + Phase D 启动前完成主要内容。

## 计划覆盖

- 认证：用户 (OIDC/JWT) / 服务间 (mTLS) / 第三方 (OAuth2)
- 授权：RBAC + ABAC，权限模型与命名
- TLS：版本下限、密码套件、证书管理
- 密钥管理：KMS / Vault / HSM 使用规范、轮换策略
- 敏感数据分级（详见 STD-03 §7）与处理流程
- API 安全：CSRF / CORS / 安全头
- 渗透测试与漏洞披露
- 监管合规映射（GDPR / PDPA / 各持牌主体）
