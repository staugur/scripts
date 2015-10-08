#!/bin/bash
#@Author:www.saintic.com
#@Description:Install puppet master or agent

clear
echo -e -n "\033[32m请输入1安装puppet master,输入2安装puppet client如果出现error.log文件,请注意查看.\033[0m"
read CODE_NUM

function HEAD() {
	if [ $(id -u) != "0" ]; then
    	echo "Error:请确保以root用户执行此脚本！"
    	exit 1
	fi
	SESTATE=$(sestatus | wc -l)
	if [ "$SESTATE" != "1" ]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config &> /dev/null
	fi
}

function error() {
	echo "Error:Please check this script and input/output!"
}

iAGENT() {
    yum install -y puppet facter openssl-devel  2>> error.log
    chkconfig puppet on
}
iMASTER() {
    yum install -y puppet puppet-server facter openssl-devel  2>> error.log
    chkconfig puppetmaster on
}
startINSTALL() {
	if [ "$CODE_NUM" = "1" ]; then
	    iMASTER
	    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8140 -j ACCEPT
	else
	    iAGENT
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8139 -j ACCEPT
    fi
}

infoVERSION() {
M_Version=$(awk -F "release" '{print $2}' /etc/redhat-release | awk '{print $1}' | awk -F . '{print $1}')

if [ "$M_Version" = "0" ]; then
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-5.noarch.rpm
    startINSTALL
	service iptables save
fi
if [ "$M_Version" = "0" ]; then
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
	startINSTALL
	service iptables save
fi
if [ "$M_Version" = "0" ]; then
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
	startINSTALL
	#firewall-cmd --permanent --zone=public --add-port=8140/tcp
    #firewall-cmd --reload
	systemctl stop firewalld ; systemctl disable firewalld
fi
rm -f v5 v6 v7 &> /dev/null
}

HEAD && infoVERSION || exit 1

  