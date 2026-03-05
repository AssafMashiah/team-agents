# Sentry Reference

## Sentry CLI

```bash
# Install
npm install -g @sentry/cli

# Auth
sentry-cli login

# List projects
sentry-cli projects list

# List recent issues
sentry-cli issues list --project <project> --limit 20

# Resolve an issue
sentry-cli issues resolve <issue-id>

# Create a release
sentry-cli releases new <version> --project <project>
sentry-cli releases finalize <version>
```

## Sentry API (REST)

```bash
export SENTRY_TOKEN="your-token"
export SENTRY_ORG="your-org"

# List issues
curl -H "Authorization: Bearer $SENTRY_TOKEN" \
  "https://sentry.io/api/0/projects/$SENTRY_ORG/<project>/issues/?limit=10"

# Resolve issue
curl -X PUT -H "Authorization: Bearer $SENTRY_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"resolved"}' \
  "https://sentry.io/api/0/issues/<issue-id>/"
```

## Source Maps

```bash
# Upload source maps (after build)
sentry-cli releases files <version> upload-sourcemaps ./dist \
  --project <project> --rewrite
```

## Alert Rules

Configure via Sentry dashboard:
- **Issue alerts**: fire on first occurrence, regression, or N occurrences in M minutes
- **Metric alerts**: fire on error rate, p95 latency thresholds
- Webhook destination: use OpenClaw gateway URL for auto-triage
