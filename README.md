# WakaTime MCP Server

A [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that provides high-signal coding analytics from your [WakaTime](https://wakatime.com/) data.

- **Direct mode**: FastMCP serves Streamable HTTP at `http://localhost:8000/mcp`
- **Proxy mode**: `mcp-proxy` exposes the server over SSE/HTTP and Caddy adds token auth (recommended for self-hosting)

## Tooling / API

| Tool | Purpose | Key arguments |
|------|---------|---------------|
| `get_coding_stats` | Detailed stats for a period | `range` (`last_7_days`, `last_30_days`, `last_6_months`, `last_year`, `all_time`) |
| `get_summary` | Activity breakdown for a date/range | `start_date`, `end_date`, `project` |
| `get_all_time` | Total coding time since account creation | `project` (optional) |
| `get_status_bar` | Current day status (like editor status bar) | (none) |
| `list_projects` | List/search tracked projects | `query` (optional) |

## Configuration

Configure via environment variables (or a `.env` file for the self-hosted scripts).

| Variable | Description | Required |
|----------|-------------|----------|
| `WAKATIME_API_KEY` | Your API key from https://wakatime.com/settings/api-key | **Yes** |
| `MCP_AUTH_KEY` | Token for auth proxy (proxy/self-hosted mode) | Proxy mode |
| `PORT` | Direct-mode port (default: `8000`) | No |

## Development (Direct mode)

1. **Install**
   ```bash
   git clone https://github.com/dpshade/wakatime-mcp.git
   cd wakatime-mcp

   python -m venv .venv
   source .venv/bin/activate

   pip install -r requirements.txt
   ```

2. **Run**
   ```bash
   export WAKATIME_API_KEY="your_wakatime_api_key_here"
   python src/server.py
   ```

3. **Connect**
   - **URL**: `http://localhost:8000/mcp`
   - **Auth**: none

## Deployment

### Option 1: Self-hosted with auth (recommended)

This mode runs the MCP server with FastMCP’s default **stdio** transport and uses `mcp-proxy` to expose it over HTTP:

```
Internet -> (optional Tailscale Funnel) -> Caddy (auth) -> mcp-proxy -> FastMCP (stdio)
                                   :8770         :8767
```

1. **Configure**
   ```bash
   cp .env.example .env
   # Edit .env: set WAKATIME_API_KEY and a strong MCP_AUTH_KEY
   ```

2. **Download Caddy (auth proxy)**
   ```bash
   curl -L https://github.com/caddyserver/caddy/releases/latest/download/caddy_linux_amd64 -o deploy/caddy
   chmod +x deploy/caddy
   ```

3. **Start**
   ```bash
   ./deploy/start.sh
   ```

4. **Endpoints**
   - **Auth proxy (recommended):**
     - SSE: `http://localhost:8770/sse`
     - Streamable HTTP: `http://localhost:8770/mcp`
   - **Internal (no auth; do not expose publicly):**
     - SSE: `http://localhost:8767/sse`
     - Streamable HTTP: `http://localhost:8767/mcp`

`mcp-proxy` also exposes a health endpoint at `http://localhost:8767/status` (and via auth proxy at `http://localhost:8770/status`).

#### Systemd (persistent)

```bash
./deploy/install-systemd.sh
sudo systemctl enable --now mcp-wakatime mcp-wakatime-auth
```

#### Optional: Tailscale Funnel

If you use Tailscale, you can publish the auth proxy port:

```bash
tailscale funnel --bg --set-path=/wakatime localhost:8770
tailscale funnel --bg 443 on
```

### Option 2: Docker

Runs `mcp-proxy` + the server in a container.

```bash
cd deploy
docker-compose up -d
```

- **Endpoint (no auth):** `http://localhost:8767/sse`
- If you want auth, run Caddy on the host (or add it to your own compose stack) and proxy to `8767`.

### Option 3: Render

This repo includes `render.yaml` for deploying the **direct** Python server.

- Set environment variable: `WAKATIME_API_KEY`
- Your service endpoint will be: `https://<your-service>/mcp`

## Client setup

### MCP Inspector

```bash
npx @modelcontextprotocol/inspector
```

Then connect using:
- Direct mode: `http://localhost:8000/mcp` (Streamable HTTP)
- Proxy mode: `http://localhost:8770/sse` (SSE)

### Poke / other hosted clients (proxy mode)

Use the auth proxy SSE endpoint and send `MCP_AUTH_KEY` via **one** of:
- `Authorization: Bearer <MCP_AUTH_KEY>`
- `X-API-Key: <MCP_AUTH_KEY>`
- `Api-Key: <MCP_AUTH_KEY>`

## Security notes

- Generate a strong auth key:
  ```bash
  openssl rand -hex 32
  ```
- Never expose the unauthenticated `mcp-proxy` port (`8767`) to the public internet.

## License

MIT
