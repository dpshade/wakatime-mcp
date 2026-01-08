FROM python:3.13-slim

RUN pip install --no-cache-dir mcp-proxy

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

ENV PORT=8080
ENV WAKATIME_API_KEY=""

EXPOSE 8080

CMD ["sh", "-c", "mcp-proxy --port=$PORT --host=0.0.0.0 --pass-environment --allow-origin='*' -- python -c \"import sys; sys.path.insert(0, '/app'); from src.server import mcp; mcp.run()\""]
