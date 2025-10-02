#!/bin/sh
set -e

echo "Starting R2 backup at $(date)"

# Check if R2 is configured
if [ -z "$R2_ACCOUNT_ID" ] || [ -z "$R2_ACCESS_KEY_ID" ] || [ -z "$R2_SECRET_ACCESS_KEY" ] || [ -z "$R2_BUCKET_NAME" ]; then
    echo "ERROR: R2 environment variables not set. Skipping backup."
    exit 1
fi

# Configure rclone for R2
mkdir -p /root/.config/rclone
cat > /root/.config/rclone/rclone.conf <<EOF
[r2]
type = s3
provider = Cloudflare
access_key_id = ${R2_ACCESS_KEY_ID}
secret_access_key = ${R2_SECRET_ACCESS_KEY}
endpoint = https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com
acl = private
EOF

# Create timestamped backup directory name
BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_PATH="pocketbase-backups/${BACKUP_DATE}"

# Sync pb_data to R2
echo "Syncing /pb/pb_data to r2:${R2_BUCKET_NAME}/${BACKUP_PATH}/"
rclone sync /pb/pb_data r2:${R2_BUCKET_NAME}/${BACKUP_PATH}/pb_data \
    --progress \
    --transfers 4 \
    --checkers 8 \
    --contimeout 60s \
    --timeout 300s \
    --retries 3 \
    --low-level-retries 10

echo "Backup completed successfully at $(date)"
echo "Backup location: r2:${R2_BUCKET_NAME}/${BACKUP_PATH}/"
