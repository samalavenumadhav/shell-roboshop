#!/bin/bash

USERID=$(id -u)
LOGS_FLODER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD 
MongoDB_HOST=mongodb.samala.online

if [ USERID -ne 0 ]; then
    echo -e "$R Please run this script with the root user" | tee -a $LOGS_FILE
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

dnf module disable nodejs -y
VALIDATE $? "Disabling Nodejs Default Version"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodeJS 20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating system User"

mkdir /app
VALIDATE $? "Creating Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading Catalogue Code"

cd /app 
VALIDATE $? "Moving to app Directory"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzip catalogue Code"

cd /app 
npm install 
VALIDATE $? "Installing Dependies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created Systemctl Service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Starting and Enabling Catalogue"

