#!/bin/bash

[ $(uname -m) = "x86_64" ] && echo "Check OK" || exit 1
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

SYS_VERSION=$(awk -F "release" '{print $2}' /etc/redhat-release | awk '{print $1}' | awk -F . '{print $1}')

UpdateTime() {
  yum -y install ntpdate
  ntpdate pool.ntp.org &>/dev/null
}


vpnsoft=/tmp/openvpn 
vpnhome=${vpnsoft}/openvpn-2.1_rc21
vpnconf=/etc/openvpn/

yum -y install wget pam-devel openssl-devel lzo-devel automake gcc gcc-c++ tar gzip patch
[ -z $vpnsoft ] && rm -rf ${vpnsoft}/* || mkdir -p $vpnsoft
cd $vpnsoft 
wget -c https://software.saintic.com/core/download/openvpn-2.1_rc21.tar.gz
wget -c https://software.saintic.com/core/download/openvpn-2.1_rc21_eurephia.patch
wget -c https://software.saintic.com/core/rpms/pkcs11-helper-1.11-4.fc22.x86_64.rpm
wget -c https://software.saintic.com/core/rpms/pkcs11-helper-devel-1.11-4.fc22.x86_64.rpm
rpm -ivh pkcs11-helper-*.rpm
UpdateTime
tar zxf openvpn-2.1_rc21.tar.gz ; cd $vpnhome
patch -p1 < ../openvpn-2.1_rc21_eurephia.patch
./configure --prefix=/usr/local/openvpn && make && make install
ln -s /usr/local/openvpn/sbin/openvpn /usr/sbin/openvpn
cd ${vpnhome}/easy-rsa/2.0/
#if you need to modify the cert info, please change the file "vars".
source ./vars
./clean-all
[ `echo $LANG` =  "zh_CN.UTF-8" ] && echo -e "\033[31m请根据提示输入证书信息:\033[0m" || echo -e "\033[31mPlease enter the certificate information:\033[0m"
./build-ca
./build-key-server server
./build-dh
[ `echo $LANG` =  "zh_CN.UTF-8" ] && echo -n -e "\033[31m请输入客户端证书名称:\033[0m" || echo -n -e "\033[31mPlease enter the name of the client certificate:\033[0m"
read C_C
./build-key $C_C
[ -d $vpnconf ] || mkdir -p $vpnconf ; cd ${vpnhome}/easy-rsa/2.0/keys
cp -fr  ca.crt  ca.key  dh1024.pem  server.key server.crt  ${C_C}.* ${vpnhome}/sample-config-files/server.conf  $vpnconf 
cp -fr ${vpnhome}/sample-scripts/openvpn.init /etc/init.d/openvpn && chmod +x /etc/init.d/openvpn && chkconfig --add openvpn && chkconfig openvpn on

/etc/init.d/openvpn start
check_sf=$(ps aux | grep openvpn | grep -v grep | wc -l)
if test $check_sf -ne 1 ; then
  echo "Start Fail"
  /usr/local/openvpn/sbin/openvpn --daemon --writepid /var/run/openvpn/server.pid --config server.conf --cd /etc/openvpn
else
  echo "Start Success"
fi

