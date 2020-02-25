#!/bin/bash

# Shell Env
SHELL_DIR=$(cd $(dirname "$0") ; pwd)
# SOFTWARE DIR
SOFT_DIR="/usr/local/src"

function precheck() {
    [ $(uname -m) = "x86_64" ] && echo "Check OK" || exit 1
    if [ $(id -u) != "0" ]; then
        echo "Error:请确保以root用户执行此脚本！" ; exit 1
    fi
    SESTATE=$(sestatus | awk '{print $NF}')
    if [ "${SESTATE}" != "disabled" ]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
        echo "检测到SELinux开启中，已经关闭，需要重启系统使其生效！"
    fi
    ntpdate ntp.pool.org
    systemctl stop firewalld
    systemctl disable firewalld
}

function install() {
    cd $SOFT_DIR
    [ "$?" != "0" ] && exit 1

    wget -c https://static.saintic.com/download/thirdApp/OpenVPN/openvpn-2.1_rc21.tar.gz
    [ "$?" != "0" ] && exit 1

    wget -c https://static.saintic.com/download/thirdApp/OpenVPN/openvpn-2.1_rc21_eurephia.patch
    [ "$?" != "0" ] && exit 1

    yum -y install pam-devel openssl-devel lzo-devel automake gcc gcc-c++ patch pkcs11-helper pkcs11-helper-devel
    [ "$?" != "0" ] && exit 1

    tar zxf openvpn-2.1_rc21.tar.gz
    [ "$?" != "0" ] && exit 1

    cd openvpn-2.1_rc21
    [ "$?" != "0" ] && exit 1

    patch -p1 < ../openvpn-2.1_rc21_eurephia.patch
    [ "$?" != "0" ] && exit 1

    ./configure && make && make install
    [ "$?" != "0" ] && exit 1

    cd easy-rsa/2.0/ && source ./vars
    #VPN证书方面环境变量，可自行修改
    export KEY_COUNTRY="CN"
    export KEY_PROVINCE="CA"
    export KEY_CITY="Beijing"
    export KEY_ORG="SaintIC"
    export KEY_EMAIL="your@email.com"

    ./clean-all

    ./build-ca --batch
    [ "$?" != "0" ] && exit 1
    
    ./build-key-server --batch server
    [ "$?" != "0" ] && exit 1

    ./build-dh
    [ "$?" != "0" ] && exit 1

    cd keys && mkdir -p /etc/openvpn
    [ "$?" != "0" ] && exit 1

    cp ca.crt ca.key dh1024.pem server.key server.crt ../../../sample-config-files/server.conf /etc/openvpn
    [ "$?" != "0" ] && exit 1

    cp ../../../sample-scripts/openvpn.init /etc/init.d/openvpn
    [ "$?" != "0" ] && exit 1
}

function postcheck() {
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    echo "现在OpenVPN已经安装完成，您需要根据实际情况修改/etc/openvpn/server.conf配置文件。"
    echo "修改完毕，您应该使用\"sysctl -p\"命令使转发功能生效(若已设置请忽略)。"
    echo "现在需要添加用户，若使用证书方式，可以使用此脚本添加或吊销用户证书：https://github.com/staugur/scripts/blob/master/services/openvpn_usermanager.sh"
    echo "启动OpenVPN命令：service openvpn start"
}

function main() {
    precheck
    install
    postcheck
}

main
