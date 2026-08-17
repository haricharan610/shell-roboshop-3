#!/bin/bash

DISK_USAGE=(df -ht | grep -v Filesystem)

DISK_THRESHHOLD=1 ## 75% minum usage
MSG=""
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)##IP → fetches instance private IP (works in AWS EC2)
while IFS=read line ## Reads each line from DISK_USAGE
do
   USAGE=$(echo $line | awk '{print $6F}' | cut -d "%" -f1)   ###$6--> use cloumns eg-75%
   PARTITION=$(echo $line | awk '{print $7F}') ## $7 --> mount point
   if [ $USAGE -ge $DISK_THRESHHOLD ]  ## trigger ALert
   then
     MSG+="HIGH Disk usage on $PARTITION: $USAGE %<br>" ### <br> represents HTML new line
   fi
done  <<< $DISK_USAGE