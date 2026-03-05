# Grafana Reference

## Grafana HTTP API

```bash
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_TOKEN="your-service-account-token"

# List dashboards
curl -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "$GRAFANA_URL/api/search?type=dash-db"

# Get dashboard by UID
curl -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "$GRAFANA_URL/api/dashboards/uid/<uid>"

# List alert rules
curl -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "$GRAFANA_URL/api/v1/provisioning/alert-rules"

# Silence an alert (mute for N hours)
curl -X POST -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "matchers": [{"name":"alertname","value":"<name>","isEqual":true}],
    "startsAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
    "endsAt": "'$(date -u -d '+4 hours' +%Y-%m-%dT%H:%M:%SZ)'"
  }' \
  "$GRAFANA_URL/api/alertmanager/grafana/api/v2/silences"
```

## Alert Rule Creation (via API)

```json
{
  "title": "High Error Rate",
  "condition": "C",
  "data": [...],
  "noDataState": "NoData",
  "execErrState": "Error",
  "for": "5m",
  "annotations": { "summary": "Error rate > 5%" },
  "labels": { "severity": "critical" }
}
```

## Common Panels to Check

- **Error rate**: requests with 5xx / total requests
- **P95 latency**: 95th percentile response time
- **Memory usage**: `container_memory_usage_bytes`
- **CPU usage**: `rate(container_cpu_usage_seconds_total[5m])`
- **Disk I/O**: `rate(node_disk_bytes_written[5m])`
