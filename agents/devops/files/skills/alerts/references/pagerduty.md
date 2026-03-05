# PagerDuty Reference

## PagerDuty REST API

```bash
export PD_TOKEN="your-api-token"
export PD_FROM="oncall@example.com"

# List triggered/acknowledged incidents
curl -H "Authorization: Token token=$PD_TOKEN" \
  "https://api.pagerduty.com/incidents?statuses[]=triggered&statuses[]=acknowledged"

# Acknowledge incident
curl -X PUT -H "Authorization: Token token=$PD_TOKEN" \
  -H "From: $PD_FROM" \
  -H "Content-Type: application/json" \
  -d '{"incident":{"type":"incident_reference","status":"acknowledged"}}' \
  "https://api.pagerduty.com/incidents/<incident-id>"

# Resolve incident
curl -X PUT -H "Authorization: Token token=$PD_TOKEN" \
  -H "From: $PD_FROM" \
  -H "Content-Type: application/json" \
  -d '{"incident":{"type":"incident_reference","status":"resolved"}}' \
  "https://api.pagerduty.com/incidents/<incident-id>"

# Create note on incident
curl -X POST -H "Authorization: Token token=$PD_TOKEN" \
  -H "From: $PD_FROM" \
  -H "Content-Type: application/json" \
  -d '{"note":{"content":"Investigating disk issue on prod-1"}}' \
  "https://api.pagerduty.com/incidents/<incident-id>/notes"
```

## Events API (trigger alert from script)

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "routing_key": "<integration-key>",
    "event_action": "trigger",
    "payload": {
      "summary": "Disk full on prod-1",
      "severity": "critical",
      "source": "devops-agent"
    }
  }' \
  "https://events.pagerduty.com/v2/enqueue"
```

## pd CLI (if installed)

```bash
pip install pdpyras   # Python SDK alternative
# Or use the official pd CLI: https://github.com/martindstone/pagerduty-cli
pd incident:list
pd incident:ack <id>
pd incident:resolve <id>
```
