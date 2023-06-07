
echo -e "${color} Install GoLang ${nocolor}"
yum install golang -y &>>/tmp/roboshop.log
stat_check $?


echo -e "${color} Add Application User${nocolor}"
  id roboshop &>>$log_file
  if [ $? -eq 1 ]; then
    useradd roboshop  &>>$log_file
  fi
  stat_check $?

echo -e "${color} Create Application Directory ${nocolor}"
  rm -rf /app   &>>$log_file
  mkdir /app
  stat_check $?


echo -e "${color} Downloading dispatch Content ${nocolor}"
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip
cd /app
unzip /tmp/dispatch.zip
stat_check $?


echo -e "${color} download the dependencies & build the software ${nocolor}"
cd /app
go mod init dispatch
go get
go build
stat_check $?


echo -e "${color} Setup SystemD Service  ${nocolor}"
cp /home/centos/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service  &>>$log_file
sed -i -e "s/roboshop_app_password/$roboshop_app_password/"  /etc/systemd/system/$component.service
stat_check $?

echo -e "${color} Start $component Service ${nocolor}"
systemctl daemon-reload  &>>$log_file
systemctl enable $component  &>>$log_file
systemctl restart $component  &>>$log_file
stat_check $?

echo -e "${color} Update Frontend Configuration ${nocolor}"
cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>/tmp/roboshop.log
stat_check $?

echo -e "${color} Starting Nginx Server ${nocolor}"
systemctl enable nginx &>>/tmp/roboshop.log
systemctl restart nginx &>>/tmp/roboshop.log
stat_check $?
