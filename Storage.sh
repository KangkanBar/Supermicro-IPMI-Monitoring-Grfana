#!/bin/bash

# Paths
IPMITOOL="/usr/bin/ipmitool"
TIMEOUT_CMD="/usr/bin/timeout"
PER_SERVER_TIMEOUT=5

# IPMI credentials
USERNAME="Username"
PASSWORD="password"

SERVERS=(
  "192.168.0.175" "192.168.0.102" "192.168.0.195" "192.168.0.63"
  "192.168.0.171" "192.168.0.96" "192.168.0.135" "192.168.0.81"
)

for server in "${SERVERS[@]}"; do
  # Add random delay to spread timestamps
  sleep $((RANDOM % 3))

  output=$($TIMEOUT_CMD $PER_SERVER_TIMEOUT $IPMITOOL -I lanplus -H "$server" -U "$USERNAME" -P "$PASSWORD" sdr list 2>&1)

  if echo "$output" | grep -q "HDD Status"; then
    line=$(echo "$output" | grep -i "HDD Status")
    hex_code=$(echo "$line" | awk -F'|' '{gsub(/ /, "", $2); print $2}')
    case "$hex_code" in
      0x00)
        status_text="Healthy"
        status_code=0
        message="OK"
        ;;
      0x01)
        status_text="OK"
        status_code=1
        message="disk healthy"
        ;;
      0x02)
        status_text="Warning"
        status_code=2
        message="drive_failure"
        ;;
      *)
        status_text="Unknown"
        status_code=4
        message="unrecognized status"
        ;;
    esac
  elif echo "$output" | grep -qi "no reading"; then
    status_text="Warning"
    status_code=2
    message="no hdd sensor"
  elif echo "$output" | grep -qi "Unable to"; then
    status_text="Warning"
    status_code=2
    message="connection_failed"
  else
    status_text="Warning"
    status_code=2
    message="no reading"
  fi

  echo "hdd_status,server=$server status_text=\"$status_text\",status_level=$status_code,message=\"$message\""
done

