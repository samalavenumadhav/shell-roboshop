#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MYSQL_HOST=mysql.samala.online

if [ $USERID -ne 0 ]; then
        echo -e "R Please run this script with root user access $N" | tee -a $LOGS_FILE
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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Coping Rabbitmq Repo"

dnf install rabbitmq-server -y &>>LOGS_FILE
VALIDATE $? "Installing Rabbitmq Server"

systemctl enable rabbitmq- &>>LOGS_FILE
systemctl start rabbitmq-server
VALIDATE $? "Enable and start Rabbitmq Server"

rabbitmqctl add_user roboshop roboshop123 &>>LOGS_FILE
VALIDATE $? "Creating User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &LOGS_FILE
VALIDATE $? "Setting Permissions"