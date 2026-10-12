#!/bin/bash
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/snap/bin

BUCKET="karthik-devops-backups-2026"
DB_NAME="appdb"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="/tmp/${DB_NAME}_${TIMESTAMP}.sql.gz"

sudo -u postgres pg_dump "$DB_NAME" | gzip > "$BACKUP_FILE"
aws s3 cp "$BACKUP_FILE" "s3://${BUCKET}/db-backups/"
rm -f "$BACKUP_FILE"

echo "$(date) Backup uploaded: $(basename "$BACKUP_FILE")"
