#!/bin/bash

DISK_USAGE=$(df -h | grep -v Filesystem)

DISK_THRESHOLD=75
MSG=""

IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

while IFS= read -r line
do
    USAGE=$(echo "$line" | awk '{print $5}' | cut -d "%" -f1)
    PARTITION=$(echo "$line" | awk '{print $6}')

    if [ "$USAGE" -ge "$DISK_THRESHOLD" ]; then
        MSG+="HIGH Disk usage on $PARTITION: $USAGE %<br>"
    fi

done <<< "$DISK_USAGE"

echo "$MSG"