#!/bin/bash

source ./common.sh
app_name=mongodb

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y  &>>$LOG_FILE
VALIDATE $? "installing mongodb org"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongod"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "editing config mongod"

systemctl restart mongod  &>>$LOG_FILE
VALIDATE $? "restarting mongod"

print_time
