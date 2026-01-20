#!/bin/bash

# Paths
IPMITOOL="/usr/bin/ipmitool"
TIMEOUT_CMD="/usr/bin/timeout"
PER_SERVER_TIMEOUT=5

# IPMI credentials
USERNAME="username"
PASSWORD="Password"

SERVERS=(
  "192.168.0.175" "192.168.0.102" "192.168.0.195" "192.168.0.11"
  "192.168.0.171" "192.168.0.96" "192.168.0.135" "192.168.0.81"
  "192.168.0.113" "192.168.0.188" "192.168.0.25" "192.168.0.37"
  "192.168.0.101" "192.168.0.196" "192.168.0.197" "192.168.0.198"
  "192.168.0.199" "192.168.0.200" "192.168.0.201" "192.168.0.202"
  "192.168.0.179" "192.168.0.180" "192.168.0.181" "192.168.0.183"
  "192.168.0.184" "192.168.0.186" "192.168.0.185" "192.168.0.106"
  "192.168.0.107" "192.168.0.108" "192.168.0.112" "192.168.0.97"
  "192.168.0.98" "192.168.0.100" "192.168.0.103" "192.168.0.136"
  "192.168.0.137" "192.168.0.138" "192.168.0.139" "192.168.0.140"
  "192.168.0.141" "192.168.0.142" "192.168.0.82" "192.168.0.83"
  "192.168.0.84" "192.168.0.88" "192.168.0.86" "192.168.0.87"
  "192.168.0.85" "192.168.0.114" "192.168.0.115" "192.168.0.116"
  "192.168.0.117" "192.168.0.118" "192.168.0.119" "192.168.0.120"
  "192.168.0.190" "192.168.0.189" "192.168.0.187" "192.168.0.191"
  "192.168.0.192" "192.168.0.193" "192.168.0.194" "192.168.0.26"
  "192.168.0.27" "192.168.0.28" "192.168.0.29" "192.168.0.31" 
  "192.168.0.32" "192.168.0.33" "192.168.0.34" "192.168.0.35" 
  "192.168.0.36" "192.168.0.12" "192.168.0.14" "192.168.0.15"
  "192.168.0.16" "192.168.0.211" "192.168.0.212" "192.168.0.213"
  "192.168.0.214" "192.168.0.215" "192.168.0.130" "192.168.0.99"
)

#loop over all servers
for HOST in "${SERVERS[@]}"; do
  # Fetch sensor data with timeout
  OUTPUT=$($TIMEOUT_CMD $PER_SERVER_TIMEOUT $IPMITOOL -I lanplus -H "$HOST" -U "$USERNAME" -P "$PASSWORD" sdr list 2>/dev/null)

  # Look for "HDD Status" line
  LINE=$(echo "$OUTPUT" | grep -Ei "^HDD Status")

  if [[ -z "$LINE" ]]; then
    # No HDD Status sensor found
    echo "ipmi_sensor,server=$HOST,name=hdd_status status_desc=\"no_sensor\",value=3"
    continue
  fi

  # Extract hex code (e.g., 0x01, 0x02)
  HEX_CODE=$(echo "$LINE" | awk -F'|' '{gsub(/ /, "", $2); print $2}')

  # Determine status based on hex code
  # IMPORTANT: Use different VALUES for different statuses
  case "$HEX_CODE" in
    0x00|0x01)
      # OK status
      VALUE=1  # IMPORTANT: 1 for OK
      STATUS_DESC="drive_present"
      ;;
    0x02|0x03|0x04)
      # Critical/Warning status
      VALUE=0  # 0 for Critical
      STATUS_DESC="drive_fault"
      ;;
    *)
      # Unknown
      VALUE=2  # 2 for Unknown
      STATUS_DESC="unknown"
      ;;
  esac

  # Output in InfluxDB line protocol format
  echo "ipmi_sensor,server=$HOST,name=hdd_status status_desc=\"$STATUS_DESC\",value=$VALUE"
done
