#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$PROJECT_DIR/.env" ]; then
    source "$PROJECT_DIR/.env"
else
    echo "Error: .env file not found at $PROJECT_DIR/.env"
    echo "Copy .env.example to .env and configure your API keys."
    exit 1
fi

# Validate required variables
if [ -z "$WAKATIME_API_KEY" ]; then
    echo "Error: WAKATIME_API_KEY not set in .env"
    exit 1
fi

if [ -z "$MCP_AUTH_KEY" ]; then
    echo "Error: MCP_AUTH_KEY not set in .env"
    exit 1
fi

cleanup() {
    echo "Shutting down..."
    kill $MCP_PID $CADDY_PID 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM

echo "Starting MCP WakaTime Server (auth-protected)..."
echo "  Auth proxy: :8770"
echo "  MCP server: :8767"

if ! command -v uv >/dev/null 2>&1; then
    echo "Error: uv is required but not installed."
    echo "Install uv: https://docs.astral.sh/uv/"
    exit 1
fi

cd "$PROJECT_DIR"
uv sync --frozen --no-install-project

WAKATIME_API_KEY="$WAKATIME_API_KEY" mcp-proxy --port=8767 --host=127.0.0.1 --stateless --allow-origin '*' --pass-environment \
  -- uv run -- python -c "import sys; sys.path.insert(0, 'src'); from server import mcp; mcp.run()" &
MCP_PID=$!

sleep 3

# Start Caddy auth proxy
MCP_AUTH_KEY="$MCP_AUTH_KEY" "$SCRIPT_DIR/caddy" run --config "$SCRIPT_DIR/Caddyfile" &
CADDY_PID=$!

echo "Ready! Endpoints:"
echo "  Local (SSE):  http://localhost:8770/sse"
echo "  Local (HTTP): http://localhost:8770/mcp"
echo ""
echo "For public access, set up Tailscale Funnel or your preferred reverse proxy."

wait
