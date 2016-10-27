#!/bin/bash

#Usage:
#$0 "172 172" "20 20" "88 91" "254"   随机生成172.20.88.0 --- 172.20.91.254的ip地址
#
#$0 "192 192" "168 168"               随机生成以 192.168 打头的ip

#$0                                   随机生成任意一个ip

#sort -k2n 的意思是： 以第二字段为标准排列，按数字排#

#if docker:
#./auto_ip.sh "172 172" "17 17" "0 254" 每次生成一个，写入到redis中，并判断IP是否存在与合法。

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

