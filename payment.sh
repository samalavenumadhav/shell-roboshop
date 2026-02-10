#1/bin/bash

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
        echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
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

dnf install python3 gcc python3-devel -y &>>LOGS_FILE
VALIDATE $? "Installing Python"

id roboshop &>>LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOGS_FILE
    VALIDATE $? "Creating System User"
else
    echo -e "Roboshop user already exit....$Y SKIPPING $N" 
fi

mkdir -p /app 
VALIDATE $? "Creating Directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>LOGS_FILE
VALIDATE $? "Downloading Payment Zip Code"

cd /app 
VALIDATE $? "Moving to App Directory"

rm -rf /app/*
VALIDATE $? "Removing Existing Code" &>>LOGS_FILE

unzip /tmp/payment.zip &>>LOGS_FILE
VALIDATE $? "Unzip Payment Code"

cd /app 
pip3 install -r requirements.txt &>>LOGS_FILE
VALIDATE $? "Installing Python Client Package"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created Systemctl Service"

systemctl daemon-reload
systemctl enable payment &>>LOGS_FILE
systemctl start payment
VALIDATE $? "Enable and Start Payment"