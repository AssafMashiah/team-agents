---
name: ssh-ops
description: "Run commands on remote servers via SSH. Use when restarting services, tailing logs, checking system health, running one-off commands on a remote host, transferring files, or diagnosing server-side issues. Covers ssh, scp, rsync, systemctl, journalctl, and tmux remote sessions."
---

# SSH Ops

## Run a Command

```bash
ssh <user>@<host> "<command>"
ssh ubuntu@192.168.1.100 "systemctl status nginx"
```

## Service Management

```bash
# Check status
ssh <host> "systemctl status <service>"

# Restart
ssh <host> "sudo systemctl restart <service>"

# Stop / start
ssh <host> "sudo systemctl stop <service> && sudo systemctl start <service>"

# Enable on boot
ssh <host> "sudo systemctl enable <service>"
```

## Log Tailing

```bash
# systemd journal
ssh <host> "sudo journalctl -u <service> -f --since '10 min ago'"

# File log
ssh <host> "sudo tail -f /var/log/<app>/app.log"

# Last N lines
ssh <host> "sudo journalctl -u <service> -n 200 --no-pager"
```

## System Health

```bash
# CPU / memory
ssh <host> "top -bn1 | head -20"
ssh <host> "free -h && df -h"

# Disk usage
ssh <host> "du -sh /* 2>/dev/null | sort -rh | head -10"

# Running processes
ssh <host> "ps aux --sort=-%cpu | head -15"

# Network connections
ssh <host> "ss -tulnp"
```

## File Transfer

```bash
# Copy file to server
scp ./file.txt <user>@<host>:/path/to/dest/

# Copy from server
scp <user>@<host>:/path/to/file.txt ./local/

# Sync directory
rsync -avz ./dist/ <user>@<host>:/var/www/html/

# Rsync with delete (mirror)
rsync -avz --delete ./dist/ <user>@<host>:/var/www/html/
```

## Remote tmux (persistent session)

```bash
# Attach or create
ssh <host> -t "tmux new-session -A -s main"

# Run command in detached session
ssh <host> "tmux new-session -d -s deploy 'bash /scripts/deploy.sh'"

# Capture output from running session
ssh <host> "tmux capture-pane -pt main"
```

## Known Hosts (in TOOLS.md)

Check `TOOLS.md` for SSH aliases, known host IPs, and key paths.

## Safety

- Prefer `--dry-run` / `--check` flags when available before destructive ops
- For `rm -rf` or `DROP TABLE` style commands: confirm with Assaf first
- Use `rsync --dry-run` before sync-with-delete
