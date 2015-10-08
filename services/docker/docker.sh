#!/bin/bash

SYS_VERSION=$(awk -F "release" '{print $2}' /etc/redhat-release | awk '{print $1}' | awk -F . '{print $1}')

BR_CONF() {
  local GET_BR_NUM=$(brctl show | wc -l)
  if [ $GET_BR_NUM -gt 1 ]; then
    local GET_BR_NAME=$(brctl show | tail -1 | awk '{print $1}')
    if [ $SYS_VERSION = "6" ]; then    
      sed -i "s/other_args=/other_args=\"-b=${GET_BR_NAME}\"/" /etc/sysconfig/docker
    fi
    if [ $SYS_VERSION = "7" ]; then
      :
      #sed -i "s/other_args=/other_args=\"-b=${GET_BR_NAME}\"/" /etc/sysconfig/docker
    fi
  fi
}

SYS_6_INS() {
  #1.installed
  rpm -q bridge-util &> /dev/null && rpm -Uih http://mirrors.yun-idc.com/epel/6/x86_64/epel-release-6-8.noarch.rpm || yum -y install bridge-utils http://mirrors.yun-idc.com/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum -y install docker-io
  #2.configure
  BR_CONF
  #3.start
  service docker start && chkconfig docker on
}

SYS_7_INS() {
  #1.installed
  yum -y install docker device-mapper-event-devel bridge-utils iptables-services
  systemctl stop firewalld ; systemctl disable firewalld
  chkconfig --add iptables ; chkconfig iptables on ; systemctl start iptables
  iptables -F ; iptables –X ; service iptables save ; service iptables resstart
  systemctl start docker
  #2.configure
  BR_CONF
  service docker start || systemctl start docker
  chkconfig docker on || systemctl enable docker
}

case $SYS_VERSION in
6)
  SYS_6_INS
;;
7)
  SYS_7_INS
;;
*)
  echo "暂只支持CentOS6/7,RHEL6/7,64位系统!"
;;
esac

#modify time timezone
#ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
