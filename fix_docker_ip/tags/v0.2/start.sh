#!/bin/bash
#start container
export LANG="zh_CN.UTF-8"
[ -e redis_action.py ] || exit 1
[ -e fix_ip.sh ] || exit 1
[ -e gen_ip.sh ] || exit 1
[ `id -u` -ne 0 ] && echo '必须使用root权限' && exit 1
LD=$(cd `dirname $0` ; pwd)

function docker_start() {
  #启动docker
  [ "$#" != "1" ] && exit 1
  cip=$(sh ${LD}/gen_ip.sh)
  cid=$(docker run -tdi --net=none $1 | cut -c 1-12)
  sh ${LD}/fix_ip.sh $cid $cip
  python ${LD}/redis_action.py start $cid $cip
}

function docker_restart() {
  [ "$#" != "1" ] && exit 1
  get_id=$1
  get_ip=$(python ${LD}/redis_action.py restart $get_id None)
  docker start $get_id ; sh ${LD}/fix_ip.sh $get_id $get_ip
}
