#!/bin/bash
#This script run at 00:00.
logs_path="/usr/local/nginx/logs"
#切分后log存放的目录
logsold_path="/wwwroot/logs"
#Y-M-D
yesterday=$(date -d "yesterday" +"%F")
LOG_D=${logsold_path}/other/$yesterday
mkdir -p $LOG_D
nginx_pid=$(cat /usr/local/nginx/logs/nginx.pid)

#重命名日志文件
cd $LOG_D
mv ${logs_path}/access.log ./ && tar zcvf ${yesterday}.access.tgz access.log --remove
mv ${logs_path}/error.log ./  && tar zcvf ${yesterday}.error.tar.gz error.log --remove

#向nginx主进程发信号重新打开日志
kill -USR1 $nginx_pid

host=$(ls -l ${logs_path}/*.access.log | awk -F " " '{print $9}' | awk -F ".access" '{print $1}' | awk -F "$logs_path/" '{print $2}')
for i in $host
do
    if [ ! -d $logsold_path/$i/$yesterday ]; then
        mkdir -p $logsold_path/$i/$yesterday
    fi
    if [ ! -f $logsold_path/$i/$yesterday/${yesterday}.access.log ]; then
        mv $logs_path/$i.access.log $logsold_path/$i/$yesterday/${yesterday}.access.log
        kill -USR1 $nginx_pid
        cd $logsold_path/$i/$yesterday && tar zcvf ${i}.${yesterday}.tgz ${yesterday}.access.log --remove
    else
        cd $logsold_path/$i/$yesterday && tar zcvf ${i}.${yesterday}.tgz ${yesterday}.access.log --remove
        kill -USR1 $nginx_pid
    fi
done