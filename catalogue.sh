#!/bin/bash

source ./common.sh
app_name=catalogue
nodejs_setup
app_setup

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
VALIDATE $? "copying catalogue service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reloading"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "starting catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying mongo repo in catalogue"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"

STATUS=$(mongosh --host mongodb.nadalla.store --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.nadalla.store </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

print_time


