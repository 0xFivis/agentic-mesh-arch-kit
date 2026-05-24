# scripts/

> arch-kit 自带脚本入口。所有脚本默认作用于 **target 仓**（消费仓），不在 kit 自身执行（已加防呆）。

## 脚本清单

| 脚本 | 用途 | 典型用法 |
|---|---|---|
| `scaffold.sh` | 把 kit 内容拷贝到一个空目录，渲染 `.tmpl`，`git init` | `mkdir my-platform && cd my-platform && bash <kit>/scripts/scaffold.sh --name my-platform` |
| `new-service.sh` | 在已 scaffold 的仓内创建新服务：实例化 `apps/<svc>/`、`contracts/<bctx>/`、`docs/services/<svc>/` | `bash <kit>/scripts/new-service.sh --type api --name orders --bctx orders --preset go-grpc-postgres` |
| `upgrade-arch-kit.sh` | 将 kit 的更新（标准 / 模板）合并到消费仓，保护本地修改 | `bash <kit>/scripts/upgrade-arch-kit.sh` |

## 设计原则

- **不污染 kit 自身**：所有脚本都校验 `TARGET != KIT_ROOT`，拒绝就地运行
- **可重入**：已存在的文件 / 目录跳过，不覆盖（同名 `.tmpl` 渲染时 skip-on-exist）
- **零 AI 动作**：脚本只做文件操作，不调用任何 AI agent；AI 注入由 `agentic-mesh-ai-kit` 负责

## 与 ai-kit 的边界

```
arch-kit/scripts/   = 结构与契约脚手架（本目录）
ai-kit/scripts/     = AI 协作矩阵注入（install.sh / upgrade.sh）
```

两者按顺序使用：先 `scaffold.sh` → 再 `ai-kit/scripts/install.sh`。
