#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <service_name>"
  exit 1
fi

SERVICE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
TARGET_DIR="$(pwd)/out/$SERVICE_NAME"

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "Error: templates directory not found at $TEMPLATES_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Cleaning $TARGET_DIR (keeping .env and ${SERVICE_NAME}.env)"
find "$TARGET_DIR" -mindepth 1 ! -name '.env' ! -name "${SERVICE_NAME}.env" -exec rm -rf {} +

echo "Initializing service: $SERVICE_NAME"

shopt -s dotglob nullglob
for template in "$TEMPLATES_DIR"/*; do
  filename="$(basename "$template")"

  if [ "$filename" = "example_app.env" ]; then
    target="$TARGET_DIR/${SERVICE_NAME}.env"
  else
    target="$TARGET_DIR/$filename"
  fi

  # Preserve existing .env and <service_name>.env
  if { [ "$filename" = ".env" ] || [ "$filename" = "example_app.env" ]; } && [ -f "$target" ]; then
    echo "Keeping existing $(basename "$target")"
    continue
  fi

  sed "s/example_app/$SERVICE_NAME/g" "$template" >"$target"
  echo "Created $(basename "$target")"
done

echo "Done."
