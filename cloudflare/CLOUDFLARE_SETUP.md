# Cloudflare Deployment

Two options for getting OpenClaw onto Cloudflare infrastructure.

---

## Option A — Cloudflare Tunnel (Recommended)

Run OpenClaw on any machine (laptop, VPS, home server) and expose it securely via Cloudflare's network. No open firewall ports. DDoS protection included.

### Steps

**1. Install `cloudflared`**
```bash
# macOS
brew install cloudflare/cloudflare/cloudflared

# Linux (Ubuntu/Debian)
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
  -o cloudflared && chmod +x cloudflared && sudo mv cloudflared /usr/local/bin/
```

**2. Authenticate**
```bash
cloudflared tunnel login
```

**3. Create the tunnel**
```bash
cloudflared tunnel create team-agents
# Outputs a Tunnel ID — copy it
```

**4. Edit `cloudflare/wrangler.toml`** — replace `REPLACE_WITH_YOUR_TUNNEL_ID` with the UUID.

**5. Create a DNS route**
```bash
cloudflared tunnel route dns team-agents openclaw.yourdomain.com
```

**6. Get the tunnel token** from the Cloudflare dashboard and add to `.env` as `CLOUDFLARE_TUNNEL_TOKEN`.

**7. Start the stack**
```bash
docker compose -f docker-compose.cloudflare.yml up -d
```

OpenClaw is now live at `https://openclaw.yourdomain.com`.

---

## Option B — Cloudflare Containers (Beta)

Cloudflare Containers lets you run Docker images natively at Cloudflare's edge. Ideal for a fully managed deployment — no server to maintain.

**Limitation:** No persistent local filesystem. OpenClaw memory/config will reset on container restarts unless you add R2 or Durable Object-backed persistence.

### Steps

**1. Build and push your custom image**
```bash
docker build -t ghcr.io/assafmashiah/team-agents:latest .
docker push ghcr.io/assafmashiah/team-agents:latest
```

**2. Deploy via Cloudflare dashboard**
- Workers & Pages → Create → Container
- Set image: `ghcr.io/assafmashiah/team-agents:latest`
- Configure environment variables (same as your `.env`)
- Set CPU/memory allocation (512MB+ recommended)

**3. For persistence** connect a Cloudflare R2 bucket and mount it at `/home/node/.openclaw`.

---

## Security Checklist

- Use a strong `OPENCLAW_GATEWAY_TOKEN` (32+ random hex characters)
- Enable Cloudflare Access in front of your OpenClaw URL for an extra auth layer
- Never expose port 18789 directly to the internet — always route through the Tunnel
- Rotate API keys periodically
- Don't commit `.env` — it's git-ignored by design
