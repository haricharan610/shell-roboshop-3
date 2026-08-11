#!/bin/bash

source ./common.sh
app_name=mongodb

check_root

cp /mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "installing mongodb org"

systemctl enable mongod
VALIDATE $? "enabling mongod"

systemctl start mongod
VALIDATE $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "editing config mongod"

systemctl restart mongod
VALIDATE $? "restarting mongod"

print_time
