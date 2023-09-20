source common.sh
component=backend

type npm &>>$log_file
if [ $? -ne 0 ]; then
  echo Install NodeJS Repos
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
  status_check

  echo Installing NodeJS
  dnf install nodejs -y &>>$log_file
  status_check
fi

echo Copy backend Service File
cp backend.service /etc/systemd/system/backend.service &>>$log_file
status_check

echo Add Application User
id expense &>>$log_file
if [ $? -ne 0 ]; then
  useradd expense &>>$log_file
fi
status_check

echo clean App content
rm -rf /app &>>$log_file
status_check

mkdir /app
cd /app

download_and_extract

echo Download Dependencies
npm install  &>>$log_file
status_check

echo Start Backend Service
systemctl daemon-reload &>>$log_file
systemctl enable backend &>>$log_file
systemctl restart backend &>>$log_file
status_check

echo Install MySQL Client
dnf install mysql -y &>>$log_file
status_check

echo Load Schema
mysql_root_password=$1
mysql -h mysql.mkdevops.online -uroot -p$mysql_root_password < /app/schema/backend.sql &>>$log_file
status_check

#ExpenseApp@1