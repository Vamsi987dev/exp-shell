#!/bin/bash
#logging and variable setup
logs_folder="/var/log/expense"
script_name=$( echo $0 | cut -d "." -f1 )
timestamp=$( date +%Y-%m-%d-%H-%M-%S )
mkdir -p $logs_folder
log_file="$logs_folder/$script_name-$timestamp.log"
userid=$( id -u )

#colour codes for ouput
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

#check root privileges
if [ $userid -ne 0 ]; then
    echo -e  " $R please run this script using root privileges $N" | tee -a $log_file
    exit 1
fi 

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R Failed $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is $G Success $N" | tee -a $log_file
    fi
}

echo "script started executing at $(date)" | tee -a $log_file

# Install mysql server
dnf install mysql-server -y &>> $log_file
validate $? "Installing mysql server"

# Enable mysql server to start on boot
systemctl enable mysqld &>> $log_file
validate $? "enabled mysql"

# Start mysql server
systemctl start mysqld &>> $log_file
validate $? "started mysql "

# Check if root password is already set
mysql -h mysql.daws81s.icu -u root -pExpenseApp@1 -e 'show databases;' &>> $log_file
if [ $? -ne 0 ]; then
    echo "mysql root password is not setup... setting it now" &>> $log_file
    mysql_secure_installation --set-root-pass ExpenseApp@1
    validate $? "setting up root password"
else
    echo "root password is already setup." | tee -a $log_file
fi 







