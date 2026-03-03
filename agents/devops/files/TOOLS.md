# TOOLS.md - DevOps Tools & Notes

## GitHub

- **Primary repo for agent backups:** `AssafMashiah/team-agents`
- **Auth:** `gh` CLI (SSH key at `~/.ssh/`)
- **All GitHub ops go through this agent** — other agents delegate via `sessions_send`
- **Daily backup cron:** backs up all agent workspaces + sessions to `team-agents`

## 1Password

- **CLI:** `op` (1Password CLI)
- **Use for:** storing API keys, bot tokens, credentials — never commit secrets to git
- **Vault:** default personal vault unless specified

## Agents in the Team

| Agent     | ID        | Purpose                        |
|-----------|-----------|--------------------------------|
| Mack      | main      | Personal assistant             |
| Fin       | invest    | Investment / financial         |
| Webmaster | webmaster | Website management             |
| Jade      | jade      | Local Llama (offline)          |
| DevOps    | devops    | GitHub, backups, infra (this)  |

## Backup Schedule

- **Daily at 02:00** — backup all workspaces + session summaries to `team-agents`
- Sensitive data (auth tokens, credentials) → 1Password only, never GitHub

## What Goes Here

- SSH host aliases
- Cron job notes
- 1Password vault/item names for known secrets

## Context7 MCP

- **Tool:** mcporter (v0.7.3) + Context7 server
- **Config:** `workspace-devops/config/mcporter.json`
- **Usage:** `mcporter call context7.resolve-library-id query="..."` then `mcporter call context7.get-library-docs libraryId="..."`
- **Purpose:** Up-to-date library/API docs for coding tasks
