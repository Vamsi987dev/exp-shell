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

dnf module disable nodejs -y &>> log_file
validate $? "disable default nodejs" 

dnf module enable nodejs:20 -y &>> log_file
validate $? "enable nodejs:20"

dnf install nodejs -y &>> log_file
validate $? "install nodejs"

useradd expense &>> log_file
validate $? "creating expense user"

