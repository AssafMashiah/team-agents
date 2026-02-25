#!/usr/bin/env bash
# =============================================================================
# setup.sh — First-time setup for OpenClaw Team Agents
# =============================================================================
set -euo pipefail

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()   { echo -e "${BLUE}[setup]${NC} $*"; }
ok()    { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; exit 1; }

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  OpenClaw Team Agents — Setup         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# --- Prerequisites -----------------------------------------------------------
log "Checking prerequisites..."
command -v docker   >/dev/null 2>&1 || error "Docker not found. Install from https://docs.docker.com/get-docker/"
ok "Docker: $(docker --version)"
docker compose version >/dev/null 2>&1 || error "Docker Compose v2 not found. Update Docker Desktop."
ok "Docker Compose v2: $(docker compose version --short)"

# --- .env setup --------------------------------------------------------------
if [ ! -f .env ]; then
    log "Creating .env from .env.example..."
    cp .env.example .env
    TOKEN=$(openssl rand -hex 32)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/REPLACE_WITH_RANDOM_32_CHAR_HEX/$TOKEN/" .env
    else
        sed -i "s/REPLACE_WITH_RANDOM_32_CHAR_HEX/$TOKEN/" .env
    fi
    warn ".env created with a random gateway token."
    warn "Open .env and set your ANTHROPIC_API_KEY (and DISCORD_BOT_TOKEN if using Discord)."
    warn "Press Enter when ready, or Ctrl-C to abort."
    read -r
else
    ok ".env already exists"
fi

# Check API key is set
source .env 2>/dev/null || true
if [ -z "${ANTHROPIC_API_KEY:-}" ] || [ "${ANTHROPIC_API_KEY}" = "sk-ant-api03-YOUR_KEY_HERE" ]; then
    error "ANTHROPIC_API_KEY is not set in .env. Please add it first."
fi
ok "ANTHROPIC_API_KEY detected"

# --- Workspace directory -----------------------------------------------------
mkdir -p workspace
ok "workspace/ directory ready"

# --- Build image -------------------------------------------------------------
log "Building custom OpenClaw image (first run may take a few minutes)..."
docker compose build
ok "Image built: team-agents:latest"

# --- Start services ----------------------------------------------------------
log "Starting OpenClaw gateway and Ollama..."
docker compose up -d
ok "Services started"

# --- Pull Ollama model -------------------------------------------------------
DEFAULT_MODEL="${OLLAMA_DEFAULT_MODEL:-llama3.1:8b}"
echo ""
log "Local LLM setup: Ollama default model is '${DEFAULT_MODEL}'"
log "This will download the model (~4-6 GB for 8b models)."
read -rp "Pull model now? [y/N] " pull_now
if [[ "${pull_now,,}" == "y" ]]; then
    docker compose exec ollama ollama pull "${DEFAULT_MODEL}"
    ok "Model ${DEFAULT_MODEL} ready"
else
    warn "Skipped. Run later: bash scripts/pull-model.sh"
fi

# --- Done! -------------------------------------------------------------------
echo ""
echo -e "${GREEN}╔═════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup complete!                            ║${NC}"
echo -e "${GREEN}╠═════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Control UI:  http://localhost:18789        ║${NC}"
echo -e "${GREEN}║  Ollama API:  http://localhost:11434        ║${NC}"
echo -e "${GREEN}╠═════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Token: see OPENCLAW_GATEWAY_TOKEN in .env  ║${NC}"
echo -e "${GREEN}╚═════════════════════════════════════════════╝${NC}"
echo ""
