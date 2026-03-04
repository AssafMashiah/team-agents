# Cloudflare API Reference

## Authentication

Use Bearer token:
```bash
curl -H "Authorization: Bearer <CF_API_TOKEN>" \
  https://api.cloudflare.com/client/v4/...
```

## DNS Records

### Create DNS Record
```bash
curl -X POST https://api.cloudflare.com/client/v4/zones/<zone-id>/dns_records \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "name": "example",
    "content": "9fdd028b.cfargotunnel.com",
    "ttl": 1,
    "proxied": true
  }'
```

### Get Zone ID
```bash
curl -X GET https://api.cloudflare.com/client/v4/zones?name=example.com \
  -H "Authorization: Bearer <token>" \
  | jq '.result[0].id'
```

### List DNS Records
```bash
curl -X GET https://api.cloudflare.com/client/v4/zones/<zone-id>/dns_records \
  -H "Authorization: Bearer <token>" \
  | jq '.result'
```

### Update DNS Record
```bash
curl -X PATCH https://api.cloudflare.com/client/v4/zones/<zone-id>/dns_records/<record-id> \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "content": "new-tunnel-id.cfargotunnel.com",
    "proxied": true
  }'
```

### Delete DNS Record
```bash
curl -X DELETE https://api.cloudflare.com/client/v4/zones/<zone-id>/dns_records/<record-id> \
  -H "Authorization: Bearer <token>"
```

## Tunnels

### List Tunnels
```bash
curl -X GET https://api.cloudflare.com/client/v4/accounts/<account-id>/cfd_tunnel \
  -H "Authorization: Bearer <token>" \
  | jq '.result'
```

### Get Tunnel Status
```bash
curl -X GET https://api.cloudflare.com/client/v4/accounts/<account-id>/cfd_tunnel/<tunnel-id>/connections \
  -H "Authorization: Bearer <token>" \
  | jq '.result'
```

### Delete Tunnel
```bash
curl -X DELETE https://api.cloudflare.com/client/v4/accounts/<account-id>/cfd_tunnel/<tunnel-id> \
  -H "Authorization: Bearer <token>"
```

## Getting Account ID

```bash
curl -X GET https://api.cloudflare.com/client/v4/accounts \
  -H "Authorization: Bearer <token>" \
  | jq '.result[0].id'
```

## Common Response Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 401 | Invalid token |
| 403 | Permission denied |
| 404 | Not found |
| 422 | Validation error (bad data) |
| 429 | Rate limited |

## Token Creation

Go to: **Cloudflare Dashboard → Account Settings → API Tokens**

Required permissions for tunnel setup:
- `Zone.Zone:read`
- `Zone.DNS:edit`
- `Account.Tunnels:manage` (optional)

Scope to specific zone:
- **Zone Resources**: Select `thrallboy.com` (or your domain)
