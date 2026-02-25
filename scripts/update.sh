#!/usr/bin/env bash
# =============================================================================
# update.sh — Pull latest OpenClaw image + latest skills/agents from this repo
# =============================================================================
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
log() { echo -e "${BLUE}[update]${NC} $*"; }
ok()  { echo -e "${GREEN}[✓]${NC} $*"; }

log "Pulling latest code from GitHub..."
git pull origin main
ok "Repo up to date"

log "Pulling latest OpenClaw base image..."
docker pull ghcr.io/phioranex/openclaw-docker:latest
ok "Base image updated"

log "Rebuilding custom team-agents image..."
docker compose build --no-cache
ok "Image rebuilt"

log "Restarting services..."
docker compose up -d
ok "Services restarted"

echo ""
echo -e "${GREEN}[✓] Update complete${NC}"
