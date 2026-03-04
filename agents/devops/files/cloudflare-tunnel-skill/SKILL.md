---
name: cloudflare-tunnel
description: Set up, manage, and troubleshoot Cloudflare Tunnels. Use when creating new tunnels, configuring DNS records, setting up ingress routes, or debugging tunnel connectivity issues. Supports both local development and production deployments with HTTPS/DNS management.
---

# Cloudflare Tunnel Setup & Management

## Quick Start

### 1. Create a Tunnel
```bash
cloudflared tunnel create <tunnel-name>
```
Returns credentials file: `~/.cloudflared/<tunnel-id>.json`

### 2. Configure Ingress Routes
Create `/etc/cloudflared/config.yml` (or `~/.cloudflared/<tunnel-name>.yml`):
```yaml
tunnel: <tunnel-id>
credentials-file: /path/to/<tunnel-id>.json

ingress:
  - hostname: example.com
    service: http://localhost:3000
  - hostname: api.example.com
    service: http://localhost:8000
  - hostname: ssh.example.com
    service: ssh://localhost:22
  - service: http_status:404
```

### 3. Create DNS Records
```bash
cloudflared tunnel route dns <tunnel-name> example.com
cloudflared tunnel route dns <tunnel-name> api.example.com
```
Or use Cloudflare API:
```bash
curl -X POST https://api.cloudflare.com/client/v4/zones/<zone-id>/dns_records \
  -H "Authorization: Bearer <cf-token>" \
  -H "Content-Type: application/json" \
  -d '{"type":"CNAME","name":"example","content":"<tunnel-id>.cfargotunnel.com","proxied":true}'
```

### 4. Run the Tunnel
```bash
# Manual
cloudflared tunnel run <tunnel-name>

# As systemd service
sudo systemctl start cloudflared
sudo systemctl status cloudflared
```

## Common Tasks

### List Tunnels
```bash
cloudflared tunnel list
```

### Delete Tunnel
```bash
cloudflared tunnel delete <tunnel-id>
```

### Test Gateway Connectivity
```bash
# From tunnel server
curl http://127.0.0.1:3000/health

# Check if cloudflared can reach it
sudo journalctl -u cloudflared -n 50 | grep -i error
```

### Restart Tunnel
```bash
sudo systemctl restart cloudflared
sudo systemctl status cloudflared
```

### View Tunnel Logs
```bash
sudo journalctl -u cloudflared -n 100
```

## Troubleshooting

### Tunnel Not Connecting
1. Verify credentials file exists and permissions: `ls -l ~/.cloudflared/<tunnel-id>.json`
2. Check service status: `sudo systemctl status cloudflared`
3. Check logs for errors: `sudo journalctl -u cloudflared -n 50 | grep ERROR`
4. Verify tunnel is registered in Cloudflare dashboard: **Tunnels → Status**

### DNS Not Resolving
1. Verify DNS record points to correct tunnel: `nslookup example.com`
2. Should resolve to Cloudflare IPs (e.g., 104.16.x.x)
3. Check DNS record in dashboard: **DNS → example.com**
4. Wait for DNS propagation (5-30 seconds)

### Curl/Browser Times Out
1. Verify gateway is running: `curl http://127.0.0.1:3000/health`
2. Check ingress config has correct hostname and service
3. Verify service is actually listening (e.g., `lsof -i :3000`)
4. Check firewall isn't blocking localhost access

### YAML Syntax Errors
```
error parsing YAML in config file at /etc/cloudflared/config.yml: yaml: line X: could not find expected ':'
```
Fix: Check indentation (spaces, not tabs) and quotes. Use reference guide below.

## Config Reference

See `references/config-guide.md` for:
- Complete YAML syntax examples
- Common ingress patterns
- Systemd service configuration
- Environment variables

See `references/api-docs.md` for:
- Cloudflare API endpoints
- Authentication methods
- DNS record management
- Tunnel status queries

## Scripts

`scripts/setup-tunnel.sh` — Automated tunnel setup (asks for domain, creates tunnel, sets DNS records)
`scripts/test-tunnel.sh` — Comprehensive diagnostic checks
`scripts/fix-yaml.sh` — Repair common config file issues
