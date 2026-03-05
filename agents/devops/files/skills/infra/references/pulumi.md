# Pulumi Reference

## Setup

```bash
pulumi login          # Pulumi Cloud (default)
pulumi login --local  # Local state (file)

# New project
pulumi new typescript
pulumi new python
```

## Stack Management

```bash
pulumi stack init production
pulumi stack select production
pulumi stack ls
pulumi stack output   # Show exported values
```

## Config & Secrets

```bash
pulumi config set key value
pulumi config set --secret apiKey "..."
pulumi config get key
```

## Common Patterns (TypeScript)

```typescript
import * as cloudflare from "@pulumi/cloudflare";

const record = new cloudflare.Record("www", {
  zoneId: config.require("zoneId"),
  name: "www",
  value: "192.0.2.1",
  type: "A",
  ttl: 3600,
});

export const recordId = record.id;
```

## Automation API (programmatic)

```typescript
import { LocalWorkspace } from "@pulumi/pulumi/automation";

const stack = await LocalWorkspace.createOrSelectStack({
  stackName: "production",
  workDir: "./infra",
});
const result = await stack.up({ onOutput: console.log });
```
