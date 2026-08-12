#!/bin/bash

USERID=$(id -u)
SOURCE_DIR=$1
DEST_DIR=$2
DAYS=${3:-14}
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/backup.log"

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" | tee -a $LOG_FILE 

if [ $USERID -ne 0 ]
then
echo -e "ERROR :: please run with root access" | tee -a $LOG_FILE
exit 1
else
echo "you are running with root access" | tee -a $LOG_FILE
fi

VALIDATE(){

if [ $1 -eq 0 ]
then
echo -e "$2 is... $G success $N" | tee -a $LOG_FILE
else
echo -e "$2 is... $R fail $N" | tee -a $LOG_FILE
fi 
}


USAGE(){
       echo -e "$R USAGE:: $N sh backup.sh <source-dir> <dest-dir> <days(optinal)>"
       exit 1
}

if [ ! -d $SOURCE_DIR ]
then
    echo -e  "$R source directory doesn't exit. please check $N"
    exit 1
fi

if [ ! -d $DEST_DIR ]
then
    echo -e "$R destination directory doesn't exit. please check $N"
    exit 1
fi

FILES=$(find $SOURCE_DIR -name "*.log" -mtime +$DAYS)

if [ ! -z "$FILES" ]
then
    echo "files to zip are :$FILES"
    TIMESTAMP=$(date +%F-%H-%M-%S)
    ZIP_FILE="$DEST_DIR/app-logs-$TIMESTAMP.zip"
    find $SOURCE_DIR -name "*.log" -mtime +$DAYS | zip -@ "$ZIP_FILE"

     if [ -f $ZIP_FILE ]
    then
        echo -e "Successfully created Zip file"

        while IFS= read -r filepath
        do
            echo "Deleting file: $filepath" | tee -a $LOG_FILE
            rm -rf $filepath
        done <<< $FILES
        echo -e "Log files older than $DAYS from source directory removed ... $G SUCCESS $N"
    else
        echo -e "Zip file creation ... $R FAILURE $N"
        exit 1
    fi
else
    echo -e "No log files found older than 14 days ... $Y SKIPPING $N"
fi