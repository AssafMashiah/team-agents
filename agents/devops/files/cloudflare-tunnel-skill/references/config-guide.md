# Cloudflare Tunnel Config Guide

## File Location
- User: `~/.cloudflared/config.yml`
- System: `/etc/cloudflared/config.yml`

## Basic Structure

```yaml
tunnel: <tunnel-id-uuid>
credentials-file: /path/to/<tunnel-id>.json

ingress:
  - hostname: example.com
    service: http://localhost:3000
  - hostname: api.example.com
    service: http://localhost:8000
  - service: http_status:404
```

## Service Types

| Type | Example | Use Case |
|------|---------|----------|
| HTTP | `http://localhost:3000` | Web servers, APIs |
| HTTPS | `https://localhost:3000` | TLS backends |
| SSH | `ssh://localhost:22` | SSH server |
| RDP | `rdp://localhost:3389` | Remote desktop |
| TCP | `tcp://localhost:5432` | Databases, raw TCP |
| WS | `ws://localhost:3000` | WebSocket |
| HTTP Status | `http_status:404` | Return HTTP error |

## Common Patterns

### Multiple Domains with Subdomains
```yaml
ingress:
  - hostname: example.com
    service: http://localhost:3000
  - hostname: "*.example.com"
    service: http://localhost:3001
  - hostname: api.example.com
    service: http://localhost:8000
  - service: http_status:404
```

### TLS and Headers
```yaml
ingress:
  - hostname: example.com
    service: http://localhost:3000
    originRequest:
      httpHostHeader: "localhost"
      tlsSkipVerify: true
      noTLSVerify: true
```

### Port-Based Routing (Hostname = IP:Port)
```yaml
ingress:
  - hostname: 192.168.1.100:443
    service: https://localhost:3000
```

## Systemd Service Config

File: `/etc/systemd/system/cloudflared.service`

```ini
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/cloudflared --config /etc/cloudflared/config.yml tunnel run
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## Common Issues

### YAML Indentation Error
❌ **Wrong** (tabs):
```yaml
tunnel:	9fdd028b-...
credentials-file:	/path
```

✅ **Correct** (spaces):
```yaml
tunnel: 9fdd028b-...
credentials-file: /path
```

### Quotes for Hostnames
If hostname contains special chars, use quotes:
```yaml
ingress:
  - hostname: "*.example.com"
    service: http://localhost:3000
```

### File Permissions
For systemd service running as root:
```bash
chmod 644 ~/.cloudflared/<tunnel-id>.json
chmod 644 /etc/cloudflared/config.yml
```

## Environment Variables

Pass via systemd service:
```ini
[Service]
Environment="HTTP_PROXY=http://proxy:3128"
Environment="CLOUDFLARED_NO_AUTOUPDATE=true"
```

Or in config:
```yaml
tunnel: <id>
credentials-file: /path
logLevel: info
logDirectory: /var/log/cloudflared
```
