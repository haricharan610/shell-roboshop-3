#!/bin/bash

source ./common.sh
app_name=cart
check_root
nodejs_setup
app_setup

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copying cart service"

systemd_setup

print_time
