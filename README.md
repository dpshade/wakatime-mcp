# WakaTime MCP Server

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that provides access to your [WakaTime](https://wakatime.com/) coding statistics. Built with [FastMCP](https://github.com/jlowin/fastmcp).

## Features

This MCP server exposes tools for accessing your WakaTime data:

| Tool | Description |
|------|-------------|
| `get_coding_stats` | Get coding statistics for a time range (7 days, 30 days, etc.) - languages, projects, editors, total time |
| `get_summary` | Get coding activity for a date or date range - perfect for daily standups |
| `get_all_time` | Get total coding time since account creation |
| `get_status_bar` | Get current status - what you're working on right now |
| `list_projects` | List all your tracked projects |

## Quick Start

### 1. Get Your WakaTime API Key

1. Go to [WakaTime Settings](https://wakatime.com/settings/api-key)
2. Copy your API key

### 2. Local Development

```bash
git clone https://github.com/YOUR_USERNAME/wakatime-mcp.git
cd wakatime-mcp

python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

pip install -r requirements.txt

export WAKATIME_API_KEY=your_api_key_here

python src/server.py
```

### 3. Test with MCP Inspector

```bash
npx @modelcontextprotocol/inspector
```

Open http://localhost:5173 and connect to `http://localhost:8000/mcp` using "Streamable HTTP" transport.

## Deployment Options

### Option 1: Render (One-Click)

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

1. Click the button above
2. Add your `WAKATIME_API_KEY` as an environment variable
3. Your server will be available at `https://your-service.onrender.com/mcp`

### Option 2: Self-Hosted with Auth (Tailscale + Caddy)

For exposing your MCP server securely over the internet with bearer token authentication:

```
Internet -> Tailscale Funnel -> Caddy (Bearer auth) -> mcp-proxy -> wakatime-mcp
              :443              :8770                   :8767        Python/FastMCP
```

#### Setup

1. Copy environment file and configure:
   ```bash
   cp .env.example .env
   # Edit .env with your WAKATIME_API_KEY and MCP_AUTH_KEY
   ```

2. Download Caddy (the auth proxy):
   ```bash
   curl -L https://github.com/caddyserver/caddy/releases/latest/download/caddy_linux_amd64 -o deploy/caddy
   chmod +x deploy/caddy
   ```

3. Start the server:
   ```bash
   ./deploy/start.sh
   ```

4. (Optional) Set up Tailscale Funnel for public access:
   ```bash
   tailscale funnel --bg --set-path=/wakatime localhost:8770
   tailscale funnel --bg 443 on
   ```

#### Systemd (Persistent)

```bash
./deploy/install-systemd.sh
sudo systemctl enable --now mcp-wakatime mcp-wakatime-auth
```

### Option 3: Docker

```bash
cd deploy
docker-compose up -d
```

## Configuration

| Environment Variable | Required | Description |
|---------------------|----------|-------------|
| `WAKATIME_API_KEY` | Yes | Your WakaTime API key |
| `MCP_AUTH_KEY` | For self-hosted | Bearer token for API authentication |
| `PORT` | No | Server port (default: 8000) |

## Usage Examples

| Tool | Example Args | Description |
|------|--------------|-------------|
| `get_coding_stats` | `{"range": "last_7_days"}` | Get stats for last 7 days |
| `get_coding_stats` | `{"range": "last_30_days"}` | Get stats for last 30 days |
| `get_summary` | `{}` | Get yesterday + today activity |
| `get_summary` | `{"start_date": "2026-01-01", "end_date": "2026-01-07"}` | Get specific date range |
| `get_all_time` | `{}` | Get total time since account creation |
| `get_all_time` | `{"project": "my-project"}` | Get all-time for specific project |
| `get_status_bar` | `{}` | Get current coding status |
| `list_projects` | `{}` | List all projects |
| `list_projects` | `{"query": "react"}` | Search projects by name |

## Rate Limits

WakaTime API allows approximately 10 requests per second. The server handles rate limit errors gracefully.

## License

MIT
