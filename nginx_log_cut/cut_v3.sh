#!/bin/bash
#查询五分钟内的nginx日志文件，并单独保存到一个项目目录中，如果五分钟内没有记录则查询四分钟到当前时间内容。
#crontab中10分钟运行一次

log_path="/usr/local/nginx/logs"
log_file="${log_path}/*.access.log"
host=$(ls -l $log_file | awk -F " " '{print $9}' | awk -F ".access" '{print $1}' | awk -F "${log_path}/" '{print $2}')

LANG="en_US.utf8"

obj() {
	objlog="$(date +%F.%T)-1.log"
	[ -z $init_shi_1 ] && init_shi_1=0
	[ -z $init_shi_2 ] && init_shi_2=0
	[ -z $init_fen_1 ] && init_fen_1=0
	sed -n '/'$(date +%Y):${init_shi_1}${init_shi_2}:$init_fen_1[0-4]'/p' $i.access.log > $objlog
	mv $objlog $sys_log_dir
}

next_obj() {
    nextlog="$(date +%F.%T)-2.log"
	sed -n '/'$(date +%Y):${init_shi_1}${init_shi_2}:$init_fen_1[5-9]'/p' $i.access.log > $nextlog
	if [ $init_fen_1 -eq 5 ]; then
		init_shi_2=$(expr $init_shi_2 + 1)
		if [ $init_shi_2 -gt 9 ] && [ $init_shi_1 -lt 2 ]; then
            init_shi_1=$(expr $init_shi_1 + 1)
            init_shi_2=$(expr $init_shi_2 - 10)
		fi
	fi
	init_fen_1=$(expr $init_fen_1 + 1)
	mv $nextlog $sys_log_dir
}

CYCLE() {
    obj
    next_obj
}

while true
do
    for i in $host
    do
        sys_log_dir="/var/log/log_sys_nginx/$i" ; [ ! -d $sys_log_dir ] && mkdir -p $sys_log_dir
        CYCLE
    done
    sleep 5m
done


