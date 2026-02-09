#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "$ Please Run This Script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi
mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2....$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying Mongo.Repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB Server"

Systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable Mongodb"

systemctl start mongod
VALIDATE $? "Starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing Remote Connections"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"