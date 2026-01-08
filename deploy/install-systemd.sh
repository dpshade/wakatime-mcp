#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

USER=$(whoami)
HOME_DIR="$HOME"

echo "Installing systemd services for MCP WakaTime Server..."
echo "  User: $USER"
echo "  Project: $PROJECT_DIR"
echo ""

sed -e "s|%USER%|$USER|g" \
    -e "s|%HOME%|$HOME_DIR|g" \
    -e "s|%PROJECT_DIR%|$PROJECT_DIR|g" \
    "$SCRIPT_DIR/mcp-wakatime.service.template" > /tmp/mcp-wakatime.service

sed -e "s|%USER%|$USER|g" \
    -e "s|%HOME%|$HOME_DIR|g" \
    -e "s|%PROJECT_DIR%|$PROJECT_DIR|g" \
    "$SCRIPT_DIR/mcp-wakatime-auth.service.template" > /tmp/mcp-wakatime-auth.service

echo "Installing service files (requires sudo)..."
sudo cp /tmp/mcp-wakatime.service /etc/systemd/system/
sudo cp /tmp/mcp-wakatime-auth.service /etc/systemd/system/

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo ""
echo "Services installed. To start:"
echo "  sudo systemctl enable --now mcp-wakatime mcp-wakatime-auth"
echo ""
echo "To check status:"
echo "  systemctl status mcp-wakatime mcp-wakatime-auth"
