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

dnf install nginx -y 
validate $? "Installing nginx"

systemctl enable nginx 
validate $? "Enabling nginx"

systemctl start nginx 
validate $? "Starting nginx"

rm -rf /usr/share/nginx/html/* 
validate $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip 
validate $? "downloading frontend code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
validate $? "Extracting the code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx
validate $? "Restarted nginx"