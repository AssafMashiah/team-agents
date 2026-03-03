# Cloudflare Tunnel Setup - Status (2026-03-02)

## What's Done ✅

- **Tunnel**: `openclaw` (ID: a64e6a16-8b9c-49ff-84c2-b0267b513be1)
- **Config**: `~/.cloudflared/openclaw-config.yml`
  - Routes `claw.thrallboy.com` → `http://localhost:18789`
- **Credentials**: `~/.cloudflared/a64e6a16-8b9c-49ff-84c2-b0267b513be1.json`
- **DNS**: `claw.thrallboy.com` CNAME → `a64e6a16.cfargotunnel.com` (proxied) ✅
- **Service**: `cloudflared-openclaw.service` (user systemd, enabled, active, 4 connections)
- **Linger**: enabled for user `thrallboy`

## Pending ⚠️ (Assaf must do manually)

### 1. Remove Cloudflare Access policy for `claw.thrallboy.com`
- Go to: https://dash.cloudflare.com → Zero Trust → Access → Applications
- Find the application for `claw.thrallboy.com` and **Delete** it
- This is blocking the tunnel (redirecting to Cloudflare login)

### 2. Delete `team.thrallboy.com` DNS record
- Go to: https://dash.cloudflare.com → thrallboy.com → DNS
- Find `team.thrallboy.com` (AAAA record, 100::) → Delete it
- It's Worker-managed (read_only via API, must delete from dashboard)
