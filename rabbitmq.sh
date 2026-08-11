#!?bin/bash

source ./common.sh
app_name=rabbitmq

echo "please enter root password"
read -s RABBITMQ_ROOT_PASSWORD

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copying rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enabling rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "starting rabbitmq server"

rabbitmqctl add_user roboshop $RABBITMQ_ROOT_PASSWORD
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_time
