#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_DIR="$SCRIPT_DIR/../out/$SERVICE"

if [ -f "$SERVICE_DIR/docker-compose.yml" ]; then
  (cd "$SERVICE_DIR" && docker compose down 2>/dev/null) || true
  rm -rf "$SERVICE_DIR"
  echo "Removed $SERVICE (compose stack + files)"
else
  docker rm -f "$SERVICE" 2>/dev/null || true
  echo "Removed $SERVICE"
fi
