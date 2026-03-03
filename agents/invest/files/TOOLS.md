# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## Slides

Slides are handled by the **main agent (Mack)**. To create or update a deck:
- Use `sessions_send(agentId="main", message="...")` to delegate
- Decks live at: `/home/thrallboy/projects/slides/<deck-name>/`
- Live at: `https://slides.thrallboy.com/<deck-name>/`
- Stack: Slidev → built via GitHub Actions → deployed to Cloudflare Pages on push to `main`

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

**All GitHub operations go through the DevOps agent.**
Do NOT run `git commit`, `git push`, or `gh` write commands directly.

To request a commit/push, use:
```
sessions_send(agentId="devops", message="Please commit [describe changes] to [repo].")
```

See `workspace-devops/GITHUB_PROTOCOL.md` for full protocol.
