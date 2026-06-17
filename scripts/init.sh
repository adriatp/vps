#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
TARGET_DIR="$(pwd)/out"

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "Error: templates directory not found at $TEMPLATES_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Cleaning $TARGET_DIR (keeping .env)"
find "$TARGET_DIR" -mindepth 1 ! -name '.env' -exec rm -rf {} +

echo "Initializing service: $SERVICE_NAME"

shopt -s dotglob nullglob
for template in "$TEMPLATES_DIR"/*; do
  filename="$(basename "$template")"
  target="$TARGET_DIR/$filename"

  if [ "$filename" = ".env" ] && [ -f "$target" ]; then
    echo "Keeping existing .env"
    continue
  fi

  sed "s/example_app/$SERVICE_NAME/g" "$template" >"$target"
  echo "Created $filename"
done

echo "Done."
