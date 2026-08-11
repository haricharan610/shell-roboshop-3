#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}


app_setup(){
id roboshop
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
 else
     echo -e "system user already created.... $Y SKIPPING $N"
fi

mkdir -p  /app &>>$LOG_FILE
VALIDATE $? "creating app directory"

cd /app &>>$LOG_FILE
VALIDATE $? "changing to app directory"

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip
VALIDATE $? "downloading $app_name"

rm -rf /app/* &>>$LOG_FILE
unzip -o /tmp/$app_name.zip &>>$LOG_FILE
VALIDATE $? "unzipping $app_name services"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"
}


nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling default nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs:20"
}


systemd_setup(){
cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
VALIDATE $? "Copying $app_name service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable $app_name &>>$LOG_FILE
systemctl start $app_name &>>$LOG_FILE
VALIDATE $? "stating $app_name"
}
maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven and Java"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moving and renaming Jar file"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Install Python3 packages"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"

    cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
    VALIDATE $? "Copying payment service"

}


python3_setup(){
id roboshop
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
 else
     echo -e "system user already created.... $Y SKIPPING $N"
fi

mkdir -p  /app &>>$LOG_FILE
VALIDATE $? "creating app directory"

cd /app &>>$LOG_FILE
VALIDATE $? "changing to app directory"

curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip
VALIDATE $? "downloading $app_name"

rm -rf /app/* &>>$LOG_FILE
unzip -o /tmp/$app_name.zip &>>$LOG_FILE
VALIDATE $? "unzipping $app_name services"

cd /app 
pip3 install -r requirements.txt
VALIDATE $? "installing pip3"
}


print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed successfully, $Y Time taken: $TOTAL_TIME seconds $N"
}

