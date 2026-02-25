#!/usr/bin/env bash
# =============================================================================
# setup-signal.sh — Register your phone number with Signal via signal-cli
# =============================================================================
# Prerequisites:
#   1. Set SIGNAL_PHONE_NUMBER in .env (e.g. +12125551234)
#   2. Start the Signal bridge: docker compose --profile signal up -d
#   3. Run this script: bash scripts/setup-signal.sh
# =============================================================================
set -euo pipefail

source .env 2>/dev/null || { echo "No .env found — run cp .env.example .env first"; exit 1; }

PHONE="${SIGNAL_PHONE_NUMBER:-}"
[ -z "$PHONE" ] && { echo "Set SIGNAL_PHONE_NUMBER in .env first (e.g. +12125551234)"; exit 1; }

API="http://localhost:${SIGNAL_API_PORT:-8080}"
echo "Registering Signal number: $PHONE"
echo "Bridge API: $API"
echo ""

echo "Step 1: Requesting verification code via SMS..."
curl -s -X POST "${API}/v1/register/${PHONE}" && echo "" || { echo "Registration request failed — is the signal-bridge running?"; exit 1; }

echo ""
read -rp "Enter the 6-digit verification code you received by SMS: " CODE

echo "Step 2: Verifying..."
curl -s -X POST "${API}/v1/register/${PHONE}/verify/${CODE}" && echo ""

echo ""
echo "✓ Signal setup complete for ${PHONE}"
echo "  Messages sent to this number will be routed through OpenClaw."
