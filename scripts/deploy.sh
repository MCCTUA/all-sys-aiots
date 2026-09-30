#!/usr/bin/env bash
# rsync repo -> VPS แล้ว docker compose up -d --build   (ใช้ซ้ำได้)
# ใช้: scripts/deploy.sh [--dry-run]
set -euo pipefail
HOST="${DEPLOY_HOST:-tua@138.199.214.5}"
DEST="${DEPLOY_DIR:-/opt/learn}"
cd "$(dirname "$0")/.."

EXCLUDES=(--exclude='.git/' --exclude='.env' --exclude='*.env' --exclude='.env.*'
  --include='.env.example' --exclude='node_modules/' --exclude='__pycache__/'
  --exclude='*.pyc' --exclude='data/' --exclude='volumes/' --exclude='postgres/'
  --exclude='node-red/data/' --exclude='n8n/data/' --exclude='.DS_Store' --exclude='.claude/')
# .env.example ต้องมาก่อน exclude '.env.*'
EXCLUDES=(--include='.env.example' "${EXCLUDES[@]}")

if [[ "${1:-}" == "--dry-run" ]]; then
  rsync -avz --delete --dry-run "${EXCLUDES[@]}" ./ "$HOST:$DEST/"
  exit 0
fi
rsync -az --delete "${EXCLUDES[@]}" ./ "$HOST:$DEST/"
ssh "$HOST" "cd $DEST && docker compose up -d --build && docker compose ps"
