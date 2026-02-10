#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
$SCRIPT_DIR=$PWD


if [ $USERID -ne 0 ]; then
    echo -e "$R Please Run This Script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
if [ $1 -ne o ]; then
        echo -e "$2....$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
else
        echo -e "$2....$S SUCCESS $N" | tee -a $LOGS_FILE
fi
 }

 dnf module disable nodejs -y
dnf module enable nodejs:20 -y &>>LOGS_FILE
VALIDATE $? "Disable Default Version and Enable NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creatind Systen User"

mkdir /app 
Validate $? "Creating directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "Downloading Cart Code"

cd /app 
unzip /tmp/cart.zip
Validate $? "Unzip Cart Code"

cd /app 
npm install
VALIDATE "Installing Dependies" 

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Created Systemctl service"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
Validate $? "Enable and Start Cart"