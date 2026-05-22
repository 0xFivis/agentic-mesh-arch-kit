<!-- REFERENCE ONLY: sanitized sample, not for production -->
# python-fastapi-postgres

后端：Python 3.12+ + FastAPI
ORM：SQLAlchemy 2.x / SQLModel
测试：pytest + httpx
构建：uv / poetry
异步：uvicorn + asyncio

## 何时选择

- 数据/ML/AI 密集任务
- 团队 Python 栈
- 需要快速接 Pandas / NumPy / scikit-learn

## 何时不选

- 极致延迟敏感（→ Go）
- 复杂并发模型 GIL 痛点
