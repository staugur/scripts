#!/bin/bash
#start container
export LANG="zh_CN.UTF-8"
[ -e redis_action.py ] || exit 1
[ `rpm -q jq bridge-utils | wc -l` -eq 2 ] || yum -y install jq bridge-utils
#[ `id -u` -ne 0 ] && echo '必须使用root权限' && exit 1
LD=$(cd `dirname $0` ; pwd)
bri_name="docker0"

function gen_ip() {
  aa=$1
  bb=$2
  cc=$3
  dd=$4
  aa=${aa:="1 254"}
  bb=${bb:="1 254"}
  cc=${cc:="1 254"}
  dd=${dd:="1 254"}
  a=`seq $aa | while read i;do echo "$i $RANDOM";done | sort -k2n | cut -d" " -f1 | tail -1`
  b=`seq $bb | while read i;do echo "$i $RANDOM";done | sort -k2n | cut -d" " -f1 | tail -1`
  c=`seq $cc | while read i;do echo "$i $RANDOM";done | sort -k2n | cut -d" " -f1 | tail -1`
  d=`seq $dd | while read i;do echo "$i $RANDOM";done | sort -k2n | cut -d" " -f1 | tail -1`
  echo "$a.$b.$c.$d"
}

function start_fix_ip() {
  cid=$1
  bind_ip=$2
  #check state
  Run=$(docker inspect $cid | jq '.[0].State.Running')
  #$(docker inspect -f '{{.State.Running}}' $cid)
  [ "$Run" = "false" ] && echo '容器没有运行' && exit 1

  #check ip format
  bind_ip=`echo $bind_ip | egrep '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
  [ ! $bind_ip ] && echo "IP地址格式不正确" && exit 3

  #start to create a peer device
  gw=$(ip addr show ${bri_name} | grep "inet\b" | awk '{print $2}' | cut -d / -f1)
  netmask=$(ip addr show ${bri_name} | grep "inet\b" | awk '{print $2}' | cut -d / -f2)
  ip=${bind_ip}/${netmask}
  #get pid
  pid=$(docker inspect $cid | jq '.[0].State.Pid')
  #$(docker inspect -f '{{.State.Pid}}' $cid)
  [ -z $pid ] && echo '获取容器PID错误' && exit 1
  bridge_name="sdp_${pid}"
  peer_name="vp_${pid}"
  [ -d /var/run/netns ] || mkdir -p /var/run/netns
  ln -s /proc/${pid}/ns/net /var/run/netns/${pid}
  ip link add ${bridge_name} type veth peer name ${peer_name}
  brctl addif ${bri_name} ${bridge_name}
  ip link set ${bridge_name} up
  ip link set ${peer_name} netns $pid
  ip netns exec $pid ip link set dev ${peer_name} name eth0
  ip netns exec $pid ip link set eth0 up
  ip netns exec $pid ip addr add $ip dev eth0
  ip netns exec $pid ip route add default via $gw
}

function docker_start() {
  #启动docker $1=ImageName
  [ "$#" != "1" ] && exit 1
  cip=gen_ip "172 172" "17 17" "0 254"
  cid=$(docker run -tdi --net=none $1 | cut -c 1-12)
  start_fix_ip $cid $cip
  python ${LD}/redis_action.py start $cid $cip
}

function docker_restart() {
  [ "$#" != "1" ] && exit 1
  containers=$(docker ps -a | awk '{print $1}' | grep -v "CONTAINER")
  if echo "${containers[@]}" | grep -w "$1" &> /dev/null;then
    get_id=$1
    get_ip=$(python ${LD}/redis_action.py restart $get_id None)
    docker start $get_id ; start_fix_ip $get_id $get_ip
  fi
}


