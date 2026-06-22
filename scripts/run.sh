#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE_NAME="$1"
ROOT_DIR="$(cd "$(dirname "$0")/../out/$SERVICE_NAME" && pwd)"
cd "$ROOT_DIR" || exit 1

docker compose up -d
