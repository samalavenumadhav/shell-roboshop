#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.samala.online

if [ $USERID -ne 0 ]; then      
        echo -e $R Plerase run this script with root user acccess $N | tee -a $LOGS_FILE
        exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2....$R FAILURE $N" | tee -a $LOGS_FILE
    else
        echo -e "$2....$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf install maven -y &>>LOGS_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOGS_FILE
    VALIDATE $? "Creating System User"
else
     echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir /app 
VALIDATE $? "Creating Directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>LOGS_FILE
VALIDATE $? "Downloading Zip Code"

cd /app 

rm -rf /app/*
VALIDATE $? "Removing Existing Code" &>>LOGS_FILE

unzip /tmp/shipping.zip &>>LOGS_FILE
VALIDATE $? "Unzip Shipping Code"

cd /app 
mvn clean package  &>>LOGS_FILE
VALIDATE $? "Installing Dependies"

mv target/shipping-1.0.jar shipping.jar &>>LOGS_FILE
VALIDATE $? "Changing File Name"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>LOGS_FILE
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable shipping &>>LOGS_FILE
systemctl start shipping
VALIDATE $? "Enable and Start Shipping"

dnf install mysql -y &>>LOGS_FILE
VALIDATE $? "Installing Mysql Client"

mysql -h mysql.samala.online -uroot -pRoboShop@1 < /app/db/schema.sql &>>LOGS_FILE
VALIDATE $? "Schema"

mysql -h mysql.samala.online -uroot -pRoboShop@1 < /app/db/app-user.sql &>>LOGS_FILE
VALIDATE $? "user"

mysql -h mysql.samala.online -uroot -pRoboShop@1 < /app/db/master-data.sql &>>LOGS_FILE
VALIDATE $? "master"

systemctl restart shipping 
VALIDATE $? "Restarting Shipping"
