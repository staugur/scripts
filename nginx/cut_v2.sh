#!/bin/bash
#查询五分钟内的nginx日志文件，并单独保存到一个项目目录中，如果五分钟内没有记录则查询四分钟到当前时间内容。
#crontab中六分钟运行一次

sys_log_dir="/var/log/log_sys_nginx"
log_path="/usr/local/nginx/logs"
log_file="${log_path}/*.access.log"
host=$(ls -l $log_file | awk -F " " '{print $9}' | awk -F ".access" '{print $1}' | awk -F "${log_path}/" '{print $2}')

#hour:minute:second
shi=$(date +%H)
fen=$(date +%M)
cut_shi=$(date +%H)
binrary=$(expr $fen - 5)
cut_fen=$(date +%M -d '5 min ago')
if [ $binrary -lt 0 ]; then
  cut_shi=$(expr $cut_shi - 1)
fi

for i in $host
do
  [ -d ${sys_log_dir}/$i ] || mkdir -p ${sys_log_dir}/$i
  nowlog="${sys_log_dir}/${i}/`date +%F.$shi-$fen`.log"
  old=grep "`date +%d/%b/%Y:`$cut_shi:$cut_fen" ${i}.access.log &> /dev/null ; echo $?
  if [ "$old" = "0" ]; then
     sed '/'$cut_shi:$cut_fen/,'$!d' ${i}.access.log >  $nowlog
  else
     sed '/'$cut_shi:$(date +%M -d '4 min ago')/,'$!d' ${i}.access.log > ${i}.log
	 if [ -z `cat ${i}.log` ]; then
        rm -f ${i}.log ; sed '/'$cut_shi:$(date +%M -d '3 min ago')/,'$!d' ${i}.access.log > ${i}.log
		if [ -z `cat ${i}.log` ]; then
		    rm -f ${i}.log ; sed '/'$cut_shi:$(date +%M -d '2 min ago')/,'$!d' ${i}.access.log > ${i}.log
		    if [ -z `cat ${i}.log` ]; then
		        rm -f ${i}.log ; sed '/'$cut_shi:$(date +%M -d '1 min ago')/,'$!d' ${i}.access.log > ${i}.log
				if [ -z `cat ${i}.log` ]; then
				    rm -f ${i}.log ; sed '/'$shi:$fen/,'$!d' ${i}.access.log >  $nowlog
				fi
			else
			    mv ${i}.log $nowlog
			fi
		else
		    mv ${i}.log $nowlog
		fi	
	 else
		mv ${i}.log $nowlog
	 fi
  fi
done


