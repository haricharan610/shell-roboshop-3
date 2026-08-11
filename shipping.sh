#!/bin/bash

source ./common.sh
app_name=shipping

check_root

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD


mkdir -p /app &>>$LOG_FILE
VALIDATE $? "creating app directory"

cd /app &>>$LOG_FILE
VALIDATE $? "changing to app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading shipping"

rm -rf /app/* &>>$LOG_FILE
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

maven_setup 

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "copying shipping"

systemd_setup &>>$LOG_FILE


dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "installing mysql"

mysql -h mysql.nadalla.store -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.nadalla.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.nadalla.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.nadalla.store -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi

systemctl restart shipping 
VALIDATE $? "restarting shipping"

print_time