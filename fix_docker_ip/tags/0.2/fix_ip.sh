#!/bin/bash
#required
[ `rpm -q jq bridge-utils | wc -l` -eq 2 ] || yum -y install jq bridge-utils

#check args
[ $# != 2 ] && echo "使用方法: $0 容器ID IP" &&  exit 1

bind_ip=$2
cid=$1
bri_name="docker0"

Run=$(docker inspect $cid | jq '.[0].State.Running')
   #$(docker inspect -f '{{.State.Running}}' $cid)
[ "$Run" = "false" ] && echo '容器没有运行' && exit 1

bind_ip=`echo $bind_ip | egrep '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
[ ! $bind_ip ] && echo "IP地址格式不正确" && exit 3

#start to create a peer device
gw=$(ip addr show ${bri_name} | grep "inet\b" | awk '{print $2}' | cut -d / -f1)
netmask=$(ip addr show ${bri_name} | grep "inet\b" | awk '{print $2}' | cut -d / -f2)
ip=${bind_ip}/${netmask}
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

