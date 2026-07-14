#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/../out"

if [ ! -d "$OUT_DIR" ]; then
  echo "Error: out directory not found. Run init.sh first."
  exit 1
fi

if ! docker network inspect internal_network >/dev/null 2>&1; then
  echo "Creating network internal_network..."
  docker network create internal_network
fi

# Stop all services
for dir in "$OUT_DIR"/*; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  if [ -f "$dir/docker-compose.yml" ]; then
    echo "Stopping $name..."
    (cd "$dir" && docker compose down 2>/dev/null || true)
  fi
done

# Start mariadb first
if [ -f "$OUT_DIR/mariadb/docker-compose.yml" ]; then
  echo "Starting mariadb..."
  (cd "$OUT_DIR/mariadb" && docker compose up -d)
else
  echo "mariadb not initialized, skipping."
fi

# Start all services except caddy and mariadb
for dir in "$OUT_DIR"/*; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  [ "$name" != "caddy" ] && [ "$name" != "mariadb" ] || continue
  if [ -f "$dir/docker-compose.yml" ]; then
    echo "Starting $name..."
    (cd "$dir" && docker compose up -d)
  fi
done

# Start caddy last
if [ -f "$OUT_DIR/caddy/docker-compose.yml" ]; then
  echo "Starting caddy..."
  (cd "$OUT_DIR/caddy" && docker compose up -d)
else
  echo "caddy not initialized, skipping."
fi

echo "Done."
