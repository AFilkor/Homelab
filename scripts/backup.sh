#!/bin/bash

# -----------------------------
# Config
# -----------------------------
REPO="/home/adam/homelab_bup/backup-repo"
BACKUP_LIST="/home/adam/homelab_bup/backup-list.txt"
BRANCH="main"

echo "=== Backup started at $(date) ==="

# -----------------------------
# Backup fájlok listája alapján
# -----------------------------
while read path; do
    # Üres sorok és kommentek kihagyása
    [[ -z "$path" || "$path" =~ ^# ]] && continue

    TARGET="$REPO$path"

    # Célkönyvtár létrehozása, ha nem létezik
    mkdir -p "$(dirname "$TARGET")"

    # Fájlok/mappák szinkronizálása
    rsync -av --delete "$path" "$TARGET"
done < "$BACKUP_LIST"

# -----------------------------
# Git commit, pull és push
# -----------------------------
cd "$REPO" || exit

# Pull a GitHub-ról, hogy szinkronban legyünk
git pull origin "$BRANCH"

# Add, commit
git add .
git commit -m "Weekly auto backup $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1

# Push a GitHub privát repo-ba (SSH)
git push origin "$BRANCH"

echo "=== Backup completed at $(date) ==="

