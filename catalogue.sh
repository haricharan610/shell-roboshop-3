#!/bin/bash

source ./common.sh
app_name=catalogue
nodejs_setup
app_setup

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying catalogue service"

systemctl daemon-reload
VALIDATE $? "daemon reloading"

systemctl enable catalogue 
VALIDATE $? "enabling catalogue"

systemctl start catalogue
VALIDATE $? "starting catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo in catalogue"

dnf install mongodb-mongosh -y
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


