# Config

This directory holds the OpenClaw gateway config backed up from `~/.openclaw/openclaw.json`.

## ⚠️ Secrets are redacted

All API keys and tokens in `openclaw.json` have been replaced with `YOUR_*` placeholders. The real values live only in `~/.openclaw/openclaw.json` on your machine — never commit them to git.

## Restoring to a new machine

1. Copy `openclaw.json` to `~/.openclaw/openclaw.json`
2. Fill in all `YOUR_*` values with your real credentials:
   - `YOUR_CF_ACCOUNT_ID` — Cloudflare account ID
   - `YOUR_ANTHROPIC_API_KEY` — from console.anthropic.com
   - `YOUR_DISCORD_BOT_TOKEN` — from discord.com/developers
   - `YOUR_OPENCLAW_GATEWAY_TOKEN` — generate with `openssl rand -hex 32`
   - `YOUR_GOOGLE_API_KEY` — for the nano-banana-pro skill
   - `YOUR_OPENAI_API_KEY` — for the openai-image-gen skill
3. Run `openclaw gateway` to start

## Skill API keys

The config references two skills with API keys:
- **nano-banana-pro** — uses a Google API key
- **openai-image-gen** — uses an OpenAI API key

Add these to your `.env` or directly into `~/.openclaw/openclaw.json` when restoring.
