---
name: alerts
description: Respond to and manage alerts from Sentry, Grafana, PagerDuty, or Uptime monitoring. Use when an alert fires, investigating an incident, triaging errors, silencing noise, or reviewing alert history. Also covers setting up basic alerting rules and webhooks.
---

# Alerts

See reference files for platform-specific details:
- `references/sentry.md` — error tracking, issue triage
- `references/grafana.md` — dashboards, alert rules
- `references/pagerduty.md` — on-call, incident management

## Incident Response Workflow

1. **Acknowledge** — grab the alert, mark it as seen to stop escalation
2. **Triage** — is it real or noise? Check recent deploys first
3. **Investigate** — use logs (ssh-ops skill), check metrics, reproduce if possible
4. **Fix or mitigate** — roll back (deploy skill) or hotfix (coding-agent + deploy)
5. **Resolve** — close the alert, update status page if applicable
6. **Post-mortem** — file a GitHub issue with what happened and how to prevent it

## Quick Checks When Alert Fires

```bash
# 1. Did a deploy just happen?
gh run list --repo <owner>/<repo> --limit 5

# 2. Check server health
ssh <host> "systemctl status <service> && journalctl -u <service> -n 50 --no-pager"

# 3. Check error rates (Sentry CLI if installed)
sentry-cli issues list --project <project> --limit 10

# 4. Check if it's a known flap (check alert history)
```

## Common Alert Patterns

| Alert Type | First Step | Likely Cause |
|------------|-----------|--------------|
| 5xx spike | Check deploy log | Bad deploy |
| Memory OOM | `free -h` on host | Memory leak / traffic spike |
| Disk full | `df -h` on host | Log files / tmp not cleaned |
| Cert expiry | `echo | openssl s_client ...` | Auto-renewal failure |
| Build failing | `gh run list` | Dependency update broke build |
| Sentry new issue | Check stack trace | Code regression |
