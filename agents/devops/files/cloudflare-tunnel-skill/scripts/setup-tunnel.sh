#!/bin/bash
# Setup Cloudflare tunnel interactively

set -e

echo "🌐 Cloudflare Tunnel Setup Wizard"
echo "=================================="
echo ""

# 1. Get tunnel name
echo "Step 1: Tunnel Name"
read -p "Enter tunnel name (e.g., 'openclaw'): " TUNNEL_NAME

if [ -z "$TUNNEL_NAME" ]; then
  echo "❌ Tunnel name cannot be empty"
  exit 1
fi

# 2. Get primary domain
echo ""
echo "Step 2: Primary Domain"
read -p "Enter primary domain (e.g., 'claw.example.com'): " PRIMARY_DOMAIN

if [ -z "$PRIMARY_DOMAIN" ]; then
  echo "❌ Domain cannot be empty"
  exit 1
fi

# 3. Get service URL
echo ""
echo "Step 3: Backend Service"
read -p "Enter service URL (e.g., 'http://127.0.0.1:18789'): " SERVICE_URL

if [ -z "$SERVICE_URL" ]; then
  echo "❌ Service URL cannot be empty"
  exit 1
fi

# 4. Confirm
echo ""
echo "📋 Configuration Summary:"
echo "  Tunnel Name: $TUNNEL_NAME"
echo "  Domain: $PRIMARY_DOMAIN"
echo "  Service: $SERVICE_URL"
echo ""

read -p "Proceed with setup? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
  echo "❌ Setup cancelled"
  exit 1
fi

# 5. Create tunnel
echo ""
echo "🚀 Creating tunnel..."
TUNNEL_OUTPUT=$(cloudflared tunnel create "$TUNNEL_NAME" 2>&1)
TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oE '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}' | head -1)

if [ -z "$TUNNEL_ID" ]; then
  echo "❌ Failed to create tunnel"
  echo "$TUNNEL_OUTPUT"
  exit 1
fi

echo "✓ Tunnel created: $TUNNEL_ID"
echo "✓ Credentials saved to: $HOME/.cloudflared/${TUNNEL_ID}.json"

# 6. Create config file
echo ""
echo "📝 Creating config file..."
CONFIG_FILE="/etc/cloudflared/config.yml"

cat > /tmp/cf-config.yml << EOF
tunnel: $TUNNEL_ID
credentials-file: $HOME/.cloudflared/${TUNNEL_ID}.json

ingress:
  - hostname: $PRIMARY_DOMAIN
    service: $SERVICE_URL
  - service: http_status:404
EOF

# Check if we can write to system config
if [ -w "$(dirname $CONFIG_FILE)" ]; then
  sudo cp /tmp/cf-config.yml "$CONFIG_FILE"
  echo "✓ Config saved to: $CONFIG_FILE"
else
  echo "⚠ Need sudo to write to $CONFIG_FILE"
  sudo cp /tmp/cf-config.yml "$CONFIG_FILE"
  echo "✓ Config saved to: $CONFIG_FILE"
fi

# 7. Create DNS record
echo ""
echo "🌐 Creating DNS record..."
read -p "Create DNS record automatically? (y/n): " CREATE_DNS

if [ "$CREATE_DNS" = "y" ]; then
  TUNNEL_ENDPOINT="${TUNNEL_ID:0:8}.cfargotunnel.com"
  echo "  Endpoint: $TUNNEL_ENDPOINT"
  
  read -p "Enter Cloudflare API token (or skip to do manually): " CF_TOKEN
  
  if [ ! -z "$CF_TOKEN" ]; then
    # Get zone ID
    ZONE_INFO=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$(echo $PRIMARY_DOMAIN | sed 's/.*\.//')" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json")
    
    ZONE_ID=$(echo "$ZONE_INFO" | python3 -c "import sys,json; print(json.load(sys.stdin)['result'][0]['id'])" 2>/dev/null)
    
    if [ -z "$ZONE_ID" ]; then
      echo "❌ Failed to get zone ID. Check your token and domain."
    else
      # Create DNS record
      DNS_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"type\": \"CNAME\", \"name\": \"$(echo $PRIMARY_DOMAIN | sed 's/\.[^.]*$//')\", \"content\": \"$TUNNEL_ENDPOINT\", \"ttl\": 1, \"proxied\": true}")
      
      if echo "$DNS_RESPONSE" | grep -q '"success":true'; then
        echo "✓ DNS record created!"
      else
        echo "❌ Failed to create DNS record"
        echo "$DNS_RESPONSE"
      fi
    fi
  else
    echo "⚠ Skipping DNS creation. Create manually:"
    echo "  Type: CNAME"
    echo "  Name: $(echo $PRIMARY_DOMAIN | sed 's/\.[^.]*$//')"
    echo "  Target: ${TUNNEL_ID:0:8}.cfargotunnel.com"
  fi
fi

# 8. Start service
echo ""
echo "🚀 Starting tunnel service..."
sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# Wait for startup
sleep 3

if sudo systemctl is-active --quiet cloudflared; then
  echo "✓ Tunnel service is running"
else
  echo "❌ Tunnel service failed to start"
  echo "  Check logs: sudo journalctl -u cloudflared -n 50"
fi

# 9. Test
echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Wait 30 seconds for DNS propagation"
echo "  2. Test: curl https://$PRIMARY_DOMAIN"
echo "  3. View logs: sudo journalctl -u cloudflared -f"
echo ""
