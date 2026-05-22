<!-- REFERENCE ONLY: sanitized sample, not for production -->
# _example/

> 完整端到端参考样例。**默认在 `scaffold.sh` 阶段被删除**，除非传 `--with-examples`。
>
> 价值：让团队第一次 setup 时有"长什么样"的真实参照；落地前删掉以保仓库干净。

## 包含

- `_example/contracts/<bctx-orders>/openapi/orders-api.v1.yaml` — 一个完整 OpenAPI 例
- `_example/contracts/<bctx-orders>/asyncapi/<bctx-orders>.order.placed.v1.yaml` — 事件例
- `_example/docs/services/svc-01-<bctx-orders>-api/README.md` — 服务详设 8 章填充例
- `_example/docs/adr/0001-choose-postgres.md` — ADR 例

## 自动删除规则

`scripts/scaffold.sh`（无 `--with-examples` 时）等价于：
```
rm -rf _example/
```

## 维护

样例 ≠ 模板。新增样例需附简短"为什么这样写"的注释。
