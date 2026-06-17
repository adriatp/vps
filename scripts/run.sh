#!/bin/bash

ROOT_DIR="$(cd "$(dirname "$0")/../out" && pwd)"
cd "$ROOT_DIR" || exit 1

docker compose up -d
