#!/bin/bash
#Template
#iplists=(
#    "ip 22 rootpasswd"
#    "hostname 2222 rootpasswd"
#)

iplists=(

)

for ip in ${iplists[@]}
do
    server=$(echo ${ip} | awk '{print $1}')
    port=$(echo ${ip} | awk '{print $2}')
    rootpasswd=$(echo ${ip} | awk '{print $3}')
    [ -x alternation.exp ] || chmod +x alternation.exp
    ./alternation.exp $server $port $rootpasswd
done
