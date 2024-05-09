#!/bin/bash

# Log file path
CACHE_LOCATION = "/LanCache"
LOG_FILE="/LanCache/logs/access.log"

# MySQL database connection parameters
DB_HOST="localhost"
DB_USER="dbusername"
DB_PASS="dbpassword"
DB_NAME="lancache_db"

LOCKFILE=/tmp/sendlogs.lock


# Check if lock file exists
if [ -e "$LOCKFILE" ]; then
    echo "Script is already running. Exiting..."
    exit 1
fi

# Create lock file
touch $LOCKFILE

# Check if the log file exists
if [ ! -f "$LOG_FILE" ]; then
  echo "Error: Log file not found: $LOG_FILE"
  exit 1
fi

echo "Script started"

declare -A aggregated_data

while IFS= read -r line; do
  read upstream status ip bytes url <<< $(echo "$line" | awk '{print $3, $4, $5, $7, $8}')

  # Skip lines with irrelevant status or missing fields
  if [[ -z "$upstream" || -z "$status" || -z "$ip" || -z "$bytes" ]]; then
    continue
  fi

  # Only process if status is HIT or MISS
  if [[ "$status" == "HIT" || "$status" == "MISS" ]]; then
    app=$(echo "$url" | awk -F'/ias/|/chunks|/depot/|/chunk|/manifest' '{
    if (NF > 3) {
      print $(NF-1)
    }
    else
    {
      print ""
    }
    }')

    # Aggregate data
    key="$ip|$upstream|$app|$status"
    ((aggregated_data["$key"] += bytes))
  else
    echo "Skipping log entry with irrelevant status: $status"
  fi
done < "$LOG_FILE"

# Insert aggregated records into the database
for key in "${!aggregated_data[@]}"; do
  IFS='|' read -r ip upstream app status <<< "$key"
  bytes="${aggregated_data[$key]}"
  echo "Inserting record into database: IP=$ip, Upstream=$upstream, App=$app, Status=$status, Bytes=$bytes"
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "INSERT INTO access_logs (Upstream, LStatus, IP, App, Bytes) VALUES ('$upstream', '$status', '$ip', '$app', '$bytes');"
done

# Clear the log file
echo "" > "$LOG_FILE"

disk_usage=$(df -BG $CACHE_LOCATION | awk 'NR==2 {print $4,$3}')

# Split the output into free and used space
free_space=$(echo "$disk_usage" | awk '{gsub(/G/, ""); print $1}')
used_space=$(echo "$disk_usage" | awk '{gsub(/G/, ""); print $2}')

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "UPDATE cache_disk SET GBUsed= '$used_space', GBFree='$free_space' ;"
# Remove lock file
rm $LOCKFILE