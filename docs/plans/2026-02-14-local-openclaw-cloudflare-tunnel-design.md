# Local OpenClaw + Cloudflare Tunnel

**Date:** 2026-02-14
**Status:** Approved
**Author:** Jade + Assaf

## Goal

Run OpenClaw locally on a dedicated Mac and expose it to the internet via a free Cloudflare Tunnel. Use Cloudflare AI Gateway for LLM routing. Connect WhatsApp and Discord channels. Total Cloudflare cost: $0/month (LLM API usage only).

This is a stepping-stone setup — designed to migrate easily to Moltworker (Cloudflare-hosted) or stay local on better hardware later.

## Architecture

```
Internet                        Your Mac
───────────────────────────────────────────────────
[WhatsApp API]  ─┐
[Discord Bot]   ─┼→ [Cloudflare Edge] → [cloudflared tunnel] → [OpenClaw Gateway :3000]
[Web Admin UI]  ─┘                                                      │
                                                                        ▼
                   [Cloudflare AI Gateway] ←──────────────── [LLM requests]
                          │
                          ▼
                   [Anthropic / OpenAI / etc.]
```

## Components

| Component | What | Cost | Runs Where |
|---|---|---|---|
| OpenClaw Gateway | Agent runtime + message router | Free (OSS) | Your Mac |
| `cloudflared` | Secure tunnel daemon | Free | Your Mac |
| Cloudflare Tunnel | Routes traffic from edge to your machine | Free | Cloudflare |
| Cloudflare AI Gateway | LLM request proxy with caching + analytics | Free | Cloudflare |
| Cloudflare Access | Auth for admin UI | Free (up to 50 users) | Cloudflare |

## Setup Steps

### Phase 1: Prerequisites

1. Install Node.js 22+ (via `nvm` or Homebrew)
2. Install `cloudflared` via Homebrew: `brew install cloudflared`
3. Clone/copy the workspace to `~/.openclaw/workspace`
4. Run `openclaw onboard` to initialize the gateway

### Phase 2: Cloudflare Tunnel

5. Log in to Cloudflare: `cloudflared tunnel login`
6. Create a tunnel: `cloudflared tunnel create openclaw`
7. Configure the tunnel to route to OpenClaw's local port (default `:3000`)
8. Set up a DNS route (e.g., `jade.yourdomain.com`) or use the free `*.cfargotunnel.com` URL
9. Run the tunnel as a launchd service so it auto-starts on boot:
   ```bash
   cloudflared service install
   ```

### Phase 3: AI Gateway

10. Create an AI Gateway in the Cloudflare dashboard (Zero Trust > AI Gateway)
11. Copy the gateway endpoint URL
12. Configure OpenClaw to route LLM requests through the AI Gateway endpoint
    - Set the base URL in OpenClaw's config to the AI Gateway URL
    - Format: `https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/{provider}`

### Phase 4: Channels

13. **WhatsApp:** Pair via OpenClaw's admin UI (scan QR code with your phone)
14. **Discord:** Create a bot in Discord Developer Portal, get the bot token, add to OpenClaw config

### Phase 5: Hardening (Optional but Recommended)

15. Add Cloudflare Access policy to protect the admin UI route
16. Prevent Mac from sleeping:
    ```bash
    # One-off
    caffeinate -s &
    # Or set in System Settings > Energy Saver: prevent sleep when display is off
    ```
17. Set up OpenClaw as a launchd service for auto-restart on crash/reboot

## Persistence & Migration

- Workspace files (`~/.openclaw/workspace/`) are the entire agent state
- No database — everything is files (markdown, JSON)
- To migrate to new hardware: copy workspace, re-run `openclaw onboard`
- To migrate to Moltworker: upload workspace to R2, deploy Moltworker, done
- Cloudflare Tunnel can be recreated in minutes on any machine

## Reliability

| Risk | Mitigation |
|---|---|
| Mac sleeps | `caffeinate -s` or Energy Saver settings |
| Internet drops | Tunnel auto-reconnects; messages queue on channel side |
| Mac reboots | launchd services auto-start both `cloudflared` and OpenClaw |
| Power outage | No mitigation without UPS; trade-off of local hosting |

## Cost Summary

| Item | Monthly Cost |
|---|---|
| Cloudflare Tunnel | $0 |
| Cloudflare AI Gateway | $0 |
| Cloudflare Access | $0 |
| OpenClaw | $0 (open source) |
| **LLM API usage** | **Variable (~$5-20 typical)** |
| **Total** | **~$5-20/month** |

## Future Migration Paths

- **More power:** Buy a Mac Mini M4, copy workspace, same setup
- **Cloud hosted:** Deploy Moltworker on Cloudflare ($15-40/month), upload workspace to R2
- **Hybrid:** Run locally + Moltworker as fallback when machine is offline
