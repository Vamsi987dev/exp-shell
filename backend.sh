#!/bin/bash
# Logging and variable setup
logs_folder="/var/log/expense"
script_name="$( echo $0 | cut -d "." -f1 )"
timestamp="$( date +%Y-%m-%d-%H-%M-%S )"
mkdir -p $logs_folder
log_file="$logs_folder/$script_name-$timestamp.log"

userid=$( id -u )

#colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Check root previleges

if [ $userid -ne 0 ]; then
    echo -e "$R please run with root access $N" | tee -a $log_file
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R Failed $N" | tee -a $log_file
    else
        echo -e "$2 is $G Success $N" | tee -a $log_file
    fi

}

echo "script started executing at $( date )" | tee -a $log_file

dnf module disable nodejs -y &>>log_file
validate $? "disable default nodejs" 

dnf module enable nodejs:20 -y &>>log_file
validate $? "enable nodejs:20"

dnf install nodejs -y &>>log_file
validate $? "install nodejs"

id expense &>>log_file
if [ $? -ne 0 ]; then
    echo "expense user doesn't exist...creating"
    useradd expense &>>log_file
    validate $? "creating expense user"
else
    echo "user already exist"
fi

mkdir -p /app
validate $? "creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>log_file
validate $? "downloading the code to tmp directory"

cd /app
rm -rf /app/* # remove the existing code
unzip /tmp/backend.zip &>>log_file
validate $? "extracting backend application code"




