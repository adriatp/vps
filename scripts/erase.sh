#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE="$1"

IMAGE=$(docker inspect -f '{{.Config.Image}}' "$SERVICE" 2>/dev/null || true)

docker rm -f "$SERVICE" 2>/dev/null || true

if [ -n "$IMAGE" ]; then
  docker rmi -f "$IMAGE" 2>/dev/null || true
fi

echo "Removed $SERVICE"
