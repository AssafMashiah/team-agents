#!/usr/bin/env bash
# =============================================================================
# pull-model.sh — Pull an Ollama model into the local LLM service
# =============================================================================
# Usage: bash scripts/pull-model.sh [model-name]
#
# Recommended models by use case:
#   llama3.2:3b     — Fast, low RAM (~2GB), great for quick tasks
#   llama3.1:8b     — Balanced performance (~8GB RAM)  [DEFAULT]
#   llama3.3:70b    — Most capable, needs 40GB+ RAM
#   mistral:7b      — Fast reasoning and coding
#   codellama:13b   — Optimised for code generation and review
#   phi3:mini       — Microsoft Phi-3, very efficient (~4GB RAM)
# =============================================================================
set -euo pipefail

MODEL=${1:-}
if [ -z "$MODEL" ]; then
    source .env 2>/dev/null || true
    MODEL="${OLLAMA_DEFAULT_MODEL:-llama3.1:8b}"
fi

echo "Pulling Ollama model: $MODEL"
docker compose exec ollama ollama pull "$MODEL"
echo ""
echo "✓ Model '$MODEL' is ready"
echo "  OpenClaw connects to Ollama via http://ollama:11434 inside the Docker network"
