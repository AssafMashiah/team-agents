#!/bin/bash
# Daily backup script - agent workspaces → AssafMashiah/team-agents
export PATH="$HOME/bin:$HOME/.npm-global/bin:/usr/local/bin:/usr/bin:/bin"
TOKEN=$(grep 'OP_SERVICE_ACCOUNT_TOKEN' ~/.bashrc | tail -1 | sed "s/export OP_SERVICE_ACCOUNT_TOKEN=//;s/\"//g")
export OP_SERVICE_ACCOUNT_TOKEN="$TOKEN"

REPO_DIR="/tmp/team-agents-backup"
DATE=$(date +%Y-%m-%d)
LOG="$HOME/.openclaw/workspace-devops/memory/backup-$DATE.log"
mkdir -p "$(dirname $LOG)"

echo "=== Backup started $(date) ===" >> $LOG

if [ -d "$REPO_DIR/.git" ]; then
  cd $REPO_DIR && git pull origin main >> $LOG 2>&1
else
  gh repo clone AssafMashiah/team-agents $REPO_DIR >> $LOG 2>&1
fi

cd $REPO_DIR
for agent in main invest webmaster devops jade; do
  # main workspace has no suffix
  if [ "$agent" = "main" ]; then
    SRC="/home/thrallboy/.openclaw/workspace"
  else
    SRC="/home/thrallboy/.openclaw/workspace-$agent"
  fi
  DEST="$REPO_DIR/agents/$agent/files"
  if [ -d "$SRC" ]; then
    mkdir -p "$DEST"
    rsync -a --exclude='*.env' --exclude='*.key' --exclude='*.pem' --exclude='node_modules' --exclude='.git' "$SRC/" "$DEST/" >> $LOG 2>&1
    echo "✅ $agent" >> $LOG
  fi
done

git add -A >> $LOG 2>&1
git commit -m "🔄 Auto-backup $DATE $(date +%H:%M)" >> $LOG 2>&1 || true
git push origin main >> $LOG 2>&1
echo "=== Done $(date) ===" >> $LOG
