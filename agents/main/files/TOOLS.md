# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## Slides

- **Location:** `/home/thrallboy/projects/slides/`
- **Live at:** `https://slides.thrallboy.com/<deck-name>/`
- **Structure:** Each deck is a folder with `slides.md`, `data.md`, `design-system.json`, `package.json`, `public/`
- **Stack:** Slidev — built via `build.js`, deployed to Cloudflare Pages via GitHub Actions on push to `main`
- **Repo:** `https://github.com/AssafMashiah/slides`
- **To add a deck:** Create folder under `/home/thrallboy/projects/slides/<deck-name>/`, commit + push → auto-deploys

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## GitHub

All GitHub operations are handled by the **DevOps agent** (id: `devops`).
Delegate via `sessions_send(agentId='devops', message='...')`.
