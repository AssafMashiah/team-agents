#!/bin/bash
# Test Cloudflare tunnel connectivity and configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Cloudflare Tunnel Diagnostic"
echo "=================================="

# 1. Check tunnel service
echo -e "\n${YELLOW}1. Checking tunnel service...${NC}"
if systemctl is-active --quiet cloudflared; then
  echo -e "${GREEN}✓ cloudflared service is running${NC}"
else
  echo -e "${RED}✗ cloudflared service is NOT running${NC}"
  echo "  Fix: sudo systemctl start cloudflared"
fi

# 2. Check config file
echo -e "\n${YELLOW}2. Checking config file...${NC}"
CONFIG_FILE="/etc/cloudflared/config.yml"
if [ -f "$CONFIG_FILE" ]; then
  echo -e "${GREEN}✓ Config file found: $CONFIG_FILE${NC}"
  
  # Validate YAML
  if command -v yamllint &> /dev/null; then
    if yamllint -d relaxed "$CONFIG_FILE" &> /dev/null; then
      echo -e "${GREEN}✓ YAML syntax is valid${NC}"
    else
      echo -e "${RED}✗ YAML syntax error${NC}"
      yamllint -d relaxed "$CONFIG_FILE"
    fi
  fi
else
  echo -e "${RED}✗ Config file not found: $CONFIG_FILE${NC}"
fi

# 3. Check credentials file
echo -e "\n${YELLOW}3. Checking credentials...${NC}"
TUNNEL_ID=$(grep "tunnel:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}' | tr -d ' ')
CREDS_FILE="$HOME/.cloudflared/${TUNNEL_ID}.json"

if [ -z "$TUNNEL_ID" ]; then
  echo -e "${RED}✗ Cannot find tunnel ID in config${NC}"
else
  echo -e "${GREEN}✓ Tunnel ID: $TUNNEL_ID${NC}"
  
  if [ -f "$CREDS_FILE" ]; then
    echo -e "${GREEN}✓ Credentials file found${NC}"
    PERMS=$(stat -f "%A" "$CREDS_FILE" 2>/dev/null || stat -c "%a" "$CREDS_FILE" 2>/dev/null)
    echo "  Permissions: $PERMS"
  else
    echo -e "${RED}✗ Credentials file not found: $CREDS_FILE${NC}"
  fi
fi

# 4. Test gateway connectivity
echo -e "\n${YELLOW}4. Testing gateway connectivity...${NC}"
GATEWAY_URL=$(grep "service:" "$CONFIG_FILE" 2>/dev/null | head -1 | awk '{print $2}')

if [ -z "$GATEWAY_URL" ]; then
  echo -e "${RED}✗ Cannot find service URL in config${NC}"
else
  echo -e "${GREEN}✓ Gateway URL: $GATEWAY_URL${NC}"
  
  # Extract host and port
  GATEWAY_HOST=$(echo "$GATEWAY_URL" | sed 's|.*://||' | cut -d: -f1)
  GATEWAY_PORT=$(echo "$GATEWAY_URL" | sed 's|.*://||' | cut -d: -f2)
  
  if curl -s -m 5 "$GATEWAY_URL/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Gateway is reachable at $GATEWAY_URL${NC}"
  else
    echo -e "${RED}✗ Gateway is NOT reachable at $GATEWAY_URL${NC}"
    echo "  Check: curl $GATEWAY_URL/health"
  fi
fi

# 5. Check DNS resolution
echo -e "\n${YELLOW}5. Checking DNS resolution...${NC}"
HOSTNAME=$(grep "hostname:" "$CONFIG_FILE" 2>/dev/null | head -1 | awk '{print $2}')

if [ -z "$HOSTNAME" ]; then
  echo -e "${RED}✗ Cannot find hostname in config${NC}"
else
  echo -e "${GREEN}✓ Checking hostname: $HOSTNAME${NC}"
  
  if nslookup "$HOSTNAME" &> /dev/null; then
    IP=$(nslookup "$HOSTNAME" 2>/dev/null | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
    echo -e "${GREEN}✓ DNS resolves to: $IP${NC}"
  else
    echo -e "${RED}✗ DNS does NOT resolve for $HOSTNAME${NC}"
  fi
fi

# 6. Check tunnel status
echo -e "\n${YELLOW}6. Checking tunnel logs...${NC}"
if systemctl is-active --quiet cloudflared; then
  ERRORS=$(journalctl -u cloudflared -n 30 2>/dev/null | grep -i "error\|fail" | wc -l)
  if [ "$ERRORS" -eq 0 ]; then
    echo -e "${GREEN}✓ No errors in tunnel logs${NC}"
  else
    echo -e "${RED}✗ Found $ERRORS errors in tunnel logs${NC}"
    journalctl -u cloudflared -n 10 | grep -i "error\|fail"
  fi
  
  CONNECTIONS=$(journalctl -u cloudflared -n 10 2>/dev/null | grep -i "Registered tunnel connection" | wc -l)
  if [ "$CONNECTIONS" -gt 0 ]; then
    echo -e "${GREEN}✓ Tunnel has $CONNECTIONS active connections${NC}"
  else
    echo -e "${YELLOW}⚠ No active tunnel connections detected${NC}"
  fi
fi

echo -e "\n${YELLOW}=================================="
echo "Diagnostic complete!${NC}"
