#!/bin/bash
#author:saintic.com
#需要邮件功能，安装mailx命令，保证邮件服务25端口开启(postfix或sendmail)
#用法：
#1.mail_admin:    改为自己的邮箱；
#2.process_list:    进程列表，需要监控的进程名，非标准或标准进程名，不适用存在docker的情况；
#3.start_scripts:    进程启动脚本列表，对应进程的启动脚本。
export LANG="zh_CN.UTF-8"
mail_admin="staugur@vip.qq.com"
process_list=(
  "nginx"
  "mysqld"
  "php-fpm"
  "httpd"
  "redis"
  "jenkins"
)
start_scripts=(
  "/usr/sbin/nginx"
  "/etc/init.d/mysqld start"
  "/etc/init.d/php-fpm start"
  "/etc/init.d/httpd start"
  "/etc/init.d/redis start"
  "/etc/init.d/jenkins start"
)

PLen=${#process_list[*]}
SLen=${#start_scripts[*]}
if [ $PLen != $SLen ];then
mailx -r "SIC_Monit@sic.emar.saintic.com" -s "ERROR:List Mismatch." $mail_admin <<EOF
进程列表数量与启动脚本列表不匹配(请联系xx解决):
    进程列表($PLen):
    ${process_list[@]}
    启动脚本列表($SLen):
    ${start_scripts[@]}
EOF
exit 1
fi

declare -i i=0
while [ 1 -gt 0 ]
do
  process=${process_list[$i]}
  process_start=${start_scripts[$i]}
  process_nums=$(ps aux | grep -v grep | grep $process | wc -l)
  if [ $process_nums -eq 0 ];then
      #判断服务进程是否存在,不存在时启动服务的命令
      $process_start
      #sleep 1
      if [ $(ps aux | grep -v grep | grep $process | wc -l) = "0" ];then
          #3秒后检测，如果进程仍不存在邮件报警
          echo "$process is down, please check, start command:${process_start}" | mailx -r "SIC_Monit@sic.emar.saintic.com" -s "ERROR:Process(${process}) is Down!!!" $mail_admin
          exit 1
      fi
  fi
  let ++i
  if [ $i -eq $PLen ];then
      break
  fi
done

