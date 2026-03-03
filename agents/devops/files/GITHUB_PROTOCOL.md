# GitHub Delegation Protocol

**Only the DevOps agent commits to GitHub.** All other agents must delegate.

## How Other Agents Request a Commit

Send a message to the `devops` session via `sessions_send`:

```
Please commit and push the following to [repo]:
- Files changed: [list]
- Commit message: "[message]"
- Branch: main (or specify)
```

DevOps will:
1. Pull latest
2. Apply the changes (or confirm they're already on disk)
3. Commit with proper attribution
4. Push
5. Reply with the commit SHA

## What DevOps Handles

- `git commit` / `git push` — all repos
- `gh pr create` / `gh pr merge` — pull requests
- `gh issue` — issue management
- GitHub Actions — trigger, monitor, re-run
- Branch management — create, protect, delete
- Secrets — via 1Password (`op`)

## What Other Agents Should NOT Do

- Run `git commit` directly
- Run `git push` directly  
- Run `gh` CLI for write operations
- Store credentials or tokens in workspace files

## Enforcement

- Global git hook at `~/.git-hooks/pre-commit` blocks commits from non-DevOps agents
- `OPENCLAW_AGENT_ID` env var identifies the committing agent
- All agents' TOOLS.md documents this policy
