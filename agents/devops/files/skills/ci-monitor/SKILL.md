---
name: ci-monitor
description: "Monitor GitHub Actions CI runs, detect failures, auto-triage errors, and retry jobs. Use when watching an active run, checking why a job failed, finding flaky tests, retrying a failed run, or setting up notifications for CI failures. Works via gh CLI."
---

# CI Monitor

## Watch a Run

```bash
# List recent runs
gh run list --repo <owner>/<repo> --limit 10

# Watch live
gh run watch <run-id> --repo <owner>/<repo>

# View run details
gh run view <run-id> --repo <owner>/<repo>
```

## Failure Triage

```bash
# See failed jobs
gh run view <run-id> --repo <owner>/<repo> --json jobs --jq '.jobs[] | select(.conclusion=="failure") | {name:.name, steps:.steps}'

# Get logs for a specific job
gh run view --log-failed --repo <owner>/<repo> <run-id>

# Download all logs
gh run download <run-id> --repo <owner>/<repo>
```

## Retry

```bash
# Retry entire run
gh run rerun <run-id> --repo <owner>/<repo>

# Retry only failed jobs
gh run rerun <run-id> --failed --repo <owner>/<repo>
```

## List Failing Workflows (pattern detection)

```bash
# Find consistently failing runs
gh run list --repo <owner>/<repo> --limit 20 --json status,conclusion,name,createdAt \
  | jq '[.[] | select(.conclusion=="failure")]'
```

## Watch for New Failures (polling loop)

```bash
# Simple: check every 60s
while true; do
  gh run list --repo <owner>/<repo> --limit 5 --json conclusion,name,updatedAt \
    | jq '.[] | select(.conclusion=="failure")'
  sleep 60
done
```

For persistent monitoring, prefer setting up a GitHub webhook or using the gh-issues skill to auto-file bugs on repeated failures.

## Common Failure Patterns

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Timeout | Slow test / infinite loop | Add timeout to job step |
| `ECONNRESET` | Flaky network in CI | Retry step with `continue-on-error` |
| `npm ERR!` | Lockfile mismatch | Run `npm ci` instead of `npm install` |
| `Permission denied` | Missing secret/token | Check repo Secrets settings |
| Node version mismatch | `.nvmrc` ignored | Add `actions/setup-node` step |
