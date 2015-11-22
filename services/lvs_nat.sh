#!/bin/bash
instance=192.168.182.130:80
mode=rr
realips=("192.168.182.128:80" "192.168.182.129:80" "127.0.0.1:80")

function AddLvsNat() {
#check rpm ipvsadm
  rpm -q ipvsadm &> /dev/null
  [ $? -eq 1 ] && yum -y install ipvsadm
#load module and ip_forward
  modprobe ip_vs
  sed -i "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/" /etc/sysctl.conf
  sysctl -p &> /dev/null
#rules
  ipvsadm -At ${instance} -s ${mode}
  for ip in ${realips[@]}
  do
    ipvsadm -a -t ${instance} -r $ip -m -w 5
  done
  ipvsadm -L -n
}

function DelLvsNat() {
  ipvsadm -D -t ${instance}
}

AddLvsNat
