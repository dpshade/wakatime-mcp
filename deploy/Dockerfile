FROM python:3.13-slim

RUN pip install --no-cache-dir uv mcp-proxy

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project

COPY src/ ./src/

ENV PORT=8080
ENV WAKATIME_API_KEY=""

EXPOSE 8080

CMD ["sh", "-c", "mcp-proxy --port=$PORT --host=0.0.0.0 --pass-environment --allow-origin='*' -- uv run -- python -c \"import sys; sys.path.insert(0, '/app'); from src.server import mcp; mcp.run()\""]
