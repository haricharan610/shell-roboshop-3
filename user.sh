#!/bin/bash

source ./common.sh
app_name=user
check_root
nodejs_setup
app_setup

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "copying user service"

systemctl daemon-reload
VALIDATE $? "daemon reloading"

systemctl enable user 
systemctl start user
VALIDATE $? "starting user"

print_time
