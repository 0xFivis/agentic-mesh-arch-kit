<!-- REFERENCE ONLY: sanitized template, fill before use -->
# ops/ · 运维资产 4 分

> 运维侧的四类资产分目录承载。**不含 `infra/`**（IaC 由平台组独立仓管理，见 v6 plan D23）。

## 4 分边界

| 子目录 | 职责 | 单位 | 关联 STD |
|---|---|---|---|
| `runbooks/` | 故障/告警的标准处置流程（SOP），按事件类型 1 文档 1 处置链 | per-event | STD-06 可观测性 |
| `dashboards/` | Grafana / Datadog 等仪表盘 JSON 导出物，按业务域 / 服务分组 | per-domain | STD-06 |
| `alerts/` | Prometheus / Datadog 告警规则源（YAML），按服务粒度 | per-service | STD-06 |
| `slo/` | 服务级 SLO 定义（availability / latency / error-budget），按服务粒度 | per-service | STD-06 / STD-08 |

## 与 testing/ 的边界

- `testing/` = **变更前**质量门（CI 阶段，阻塞合并）
- `ops/` = **运行期**可观测与可恢复（生产阶段）

两者不重叠：testing 不放 alert/runbook，ops 不放测试代码。

## 文件命名

- 每子目录均有 `_template/`（脚手架占位）+ `_example/`（参考样本，v0.2+ 填充）
- `runbooks/<event-name>.md` · `alerts/<service>.yaml` · `slo/<service>-<sli>.md`

## 红线

- 凡告警都必须有对应 runbook（无 runbook 的 alert 不准上生产）
- 凡服务都必须有 SLO（即便初版只声明 99.0% availability）
- runbook 必须含「回滚步骤」与「升级条件」两节
