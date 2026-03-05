---
name: deploy
description: "Deploy applications to Cloudflare Pages, Docker hosts, or Kubernetes. Use when deploying a new version, rolling back a bad release, checking deployment status, triggering a manual deploy, or diagnosing deployment failures. Covers Cloudflare Pages (wrangler + GitHub Actions), Docker (build/push/run), and kubectl-based k8s rollouts."
---

# Deploy

## Cloudflare Pages (primary stack)

### Deploy via git push
```bash
git push origin main   # GitHub Actions triggers build → auto-deploy to CF Pages
```

### Check deployment status
```bash
# Via gh CLI
gh run list --repo <owner>/<repo> --limit 5
gh run watch <run-id>

# Via wrangler
wrangler pages deployment list --project-name <project>
```

### Trigger manual deploy (wrangler)
```bash
wrangler pages deploy ./dist --project-name <project>
```

### Rollback
```bash
# List recent deployments
wrangler pages deployment list --project-name <project>
# Promote a previous deployment
wrangler pages deployment tail <deployment-id>
# Redeploy old commit
git revert HEAD && git push
```

### Environment variables
```bash
wrangler pages secret put <KEY> --project-name <project>
wrangler pages secret list --project-name <project>
```

See `references/cloudflare-pages.md` for project-specific details and gotchas.

---

## Docker

```bash
# Build and tag
docker build -t <image>:<tag> .

# Push to registry
docker push <image>:<tag>

# Run on remote host (via ssh-ops skill)
ssh <host> "docker pull <image>:<tag> && docker stop <container> && docker run -d --name <container> <image>:<tag>"

# Check logs
docker logs -f <container>

# Rollback: restart with previous tag
docker stop <container>
docker run -d --name <container> <image>:<prev-tag>
```

---

## Kubernetes

```bash
# Rollout new image
kubectl set image deployment/<name> <container>=<image>:<tag> -n <namespace>

# Watch rollout
kubectl rollout status deployment/<name> -n <namespace>

# Rollback
kubectl rollout undo deployment/<name> -n <namespace>
kubectl rollout history deployment/<name> -n <namespace>

# Check pods
kubectl get pods -n <namespace>
kubectl logs -f <pod> -n <namespace>
```

---

## Deployment Checklist

Before deploying:
1. Confirm CI is green (`gh run list`)
2. Check no other deploy is in progress
3. Verify env vars/secrets are set for target env

After deploying:
1. Confirm deployment succeeded (status check)
2. Quick smoke test (curl the endpoint)
3. Watch logs for 2-3 min for errors
