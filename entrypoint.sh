#!/bin/sh
set -e

# Start PocketBase in the background to initialize the database
/pb/pocketbase serve --http=0.0.0.0:8090 &
PB_PID=$!

# Wait for PocketBase to start
sleep 3

# Create superuser if credentials are provided
if [ -n "$SUPERUSER_EMAIL" ] && [ -n "$SUPERUSER_PASSWORD" ]; then
    echo "Creating superuser account..."
    /pb/pocketbase superuser upsert "$SUPERUSER_EMAIL" "$SUPERUSER_PASSWORD"
fi

# Stop the background process
kill $PB_PID
wait $PB_PID

# Start PocketBase in foreground
exec /pb/pocketbase serve --http=0.0.0.0:8090
