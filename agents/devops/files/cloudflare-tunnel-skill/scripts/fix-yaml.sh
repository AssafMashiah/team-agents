#!/bin/bash
# Fix common Cloudflare tunnel config file issues

set -e

CONFIG_FILE="${1:-/etc/cloudflared/config.yml}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "🔧 Fixing Cloudflare tunnel config: $CONFIG_FILE"

# Backup original
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
echo "✓ Backup created: ${CONFIG_FILE}.bak"

# Fix: Remove spaces from tunnel ID
sed -i 's/tunnel: \([^ ]*\) \([^ ]*\)/tunnel: \1\2/g' "$CONFIG_FILE"

# Fix: Remove tabs, replace with spaces
sed -i 's/\t/  /g' "$CONFIG_FILE"

# Fix: Ensure proper YAML indentation for ingress items
# If a line has "- hostname:" but wrong indentation, fix it
sed -i 's/^  *- hostname:/  - hostname:/g' "$CONFIG_FILE"
sed -i 's/^  *service:/    service:/g' "$CONFIG_FILE"

# Fix: Remove trailing whitespace
sed -i 's/[[:space:]]*$//' "$CONFIG_FILE"

# Validate YAML syntax if yamllint available
if command -v yamllint &> /dev/null; then
  if yamllint -d relaxed "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "✓ YAML syntax is valid"
  else
    echo "⚠ YAML syntax still has issues:"
    yamllint -d relaxed "$CONFIG_FILE" | head -5
    exit 1
  fi
else
  echo "⚠ yamllint not installed, skipping YAML validation"
fi

echo "✓ Config file fixed!"
echo ""
echo "Next steps:"
echo "  1. Review the file: cat $CONFIG_FILE"
echo "  2. Restart tunnel: sudo systemctl restart cloudflared"
echo "  3. Check status: sudo systemctl status cloudflared"
