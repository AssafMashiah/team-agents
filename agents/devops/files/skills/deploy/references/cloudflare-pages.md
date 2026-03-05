# Cloudflare Pages — Project Reference

## Active Projects

| Project | Repo | Live URL | Branch |
|---------|------|----------|--------|
| slides | AssafMashiah/slides | https://slides.thrallboy.com | main |

## Wrangler Auth

Credentials are stored via `wrangler login` or in `cf-creds.env`.

Load credentials:
```bash
source ~/projects/slides/cf-creds.env
```

## Build Config (slides project)

- Build command: `node build.js`
- Output directory: `dist/`
- Each deck subfolder gets its own route: `/deck-name/*`

## Common Issues

**Deploy stuck / not triggering:**
- Check GitHub Actions: `gh run list --repo AssafMashiah/slides`
- Sometimes CF Pages webhook needs a re-push: `git commit --allow-empty -m "trigger" && git push`

**Environment variables missing:**
- Add via wrangler: `wrangler pages secret put KEY --project-name slides`
- Or via CF dashboard → Pages → project → Settings → Environment variables

**Build failing:**
- Check build logs in CF dashboard or `wrangler pages deployment tail <id>`
- Node version mismatch: set `NODE_VERSION=20` in CF env vars
