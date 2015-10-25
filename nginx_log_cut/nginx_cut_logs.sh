#!/bin/bash
#This script run at 00:00.
logs_path="/data/app/nginx/logs"
#切分后log存放的目录
bak_path="/data/logs"

yesterday=$(date -d "yesterday" +"%Y%m%d")
nginx_pid=$(cat ${logs_path}/nginx.pid)
host=$(ls -l ${logs_path}/*.access.log | awk -F " " '{print $9}' | awk -F ".access" '{print $1}' | awk -F "$logs_path/" '{print $2}')
for i in $host
do
  program=${bak_path}/$i
  bakfile=${program}/${yesterday}.tgz
  [ -d $program ] || mkdir -p $program
  if [ -f $bakfile ];then
    echo "已存在备份文件";exit 1
  else
    mv ${logs_path}/${i}.access.log $program;
    cd $program ; tar zcf $bakfile ${i}.access.log --remove
  fi
done
[ -d ${bak_path}/all ] || mkdir -p ${bak_path}/all
cd ${bak_path}/all
mv ${logs_path}/access.log . && tar zcf ${yesterday}.access.tgz access.log --remove
mv ${logs_path}/error.log . && tar zcf ${yesterday}.error.tar.gz error.log --remove

#向nginx主进程发信号重新打开日志
kill -USR1 $nginx_pid
