#!/bin/bash

# Cache and Log file paths
CACHE_LOCATION="/LanCache/"
LOGS_LOCATION="$CACHE_LOCATION/logs"
LOG_FILE="$LOGS_LOCATION/access.log"

# MySQL database connection parameters
DB_HOST="localhost"
DB_USER="dbusername"
DB_PASS="dbpassword"
DB_NAME="lancache_db"

# Path to a file that, when created, indicates the script is already active
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

# df prints used and free size, and does not list every directory, which makes this faster than du for the cache/data folder
disk_usage_cache=$(df -BK $CACHE_LOCATION | awk 'NR==2 {print $4,$3}')

# Split the output into free and used space
free_space_cache=$(echo "$disk_usage_cache" | awk '{gsub(/K/, ""); print $1}')
used_space_cache=$(echo "$disk_usage_cache" | awk '{gsub(/K/, ""); print $2}')

update_cache_usage_sql="UPDATE cache_disk SET KiBUsed= '$used_space_cache', KiBFree='$free_space_cache' WHERE Location='data'"

disk_usage_logs=$(du -BK $LOGS_LOCATION | awk 'NR==1 {print $1}')

# Split the output into free and used space
used_space_logs=$(echo "$disk_usage_logs" | awk '{gsub(/K/, ""); print $1}')

update_logs_usage_sql="UPDATE cache_disk SET KiBUsed= '$used_space_logs', KiBFree='$free_space_cache' WHERE Location='logs'"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$update_cache_usage_sql; $update_logs_usage_sql;"

# Remove lock file
rm $LOCKFILE