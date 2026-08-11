#!/bin/bash

source ./common.sh
app_name=payment

check_root
python3_setup
python_setup
systemd_setup
print_time