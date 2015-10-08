#!/bin/bash
#查询一个小时内的nginx日志文件，并单独保存到一个项目目录中，如果一小时内没有记录则不生成新日志。

sys_log_dir=/var/log/log_sys_nginx/
log_path="/usr/local/nginx/logs"
log_file="${log_path}/*.access.log"
cut_time=$(expr $(date +%H) - 1)
host=$(ls -l $log_file | awk -F " " '{print $9}' | awk -F ".access" '{print $1}' | awk -F "${log_path}/" '{print $2}')

for i in $host
do
  cd $log_path ;
  start_line=$(nl $i.access.log | egrep `date +%d/%b/%Y:$cut_time` | awk '{print $1}' | head -1)
  end_line=$(nl $i.access.log | egrep `date +%d/%b/%Y:%H` | awk '{print $1}' | tail -1)
  program="${sys_log_dir}/$i"
  [ -d $program ] || mkdir -p $program
  if [ -z $start_line ] || [ -z $end_line ]; then
    :
  else
    tail -$(expr $end_line - $start_line  + 1) $i.access.log > $i.`date +%F.$cut_time~%H`.log
    mv $i.`date +%F.$cut_time~%H`.log $program/`date +%F.$cut_time~%H`.log
  fi
done

