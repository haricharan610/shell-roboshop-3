#!/bin/bash

source ./common.sh
app_name=frontend
check_root

dnf module disable nginx -y
VALIDATE $? "disabling nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "enabling nginx:1.24"

dnf install nginx -y
VALIDATE $? "installing nginx"

systemctl enable nginx 
VALIDATE $? "enabling nginx"

systemctl start nginx 
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing HTML"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "doenloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzipping frontend"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying nginx conf"

systemctl restart nginx 
VALIDATE $? "restarting nginx"

print_time


