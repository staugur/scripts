#!/bin/bash
#######################################################
# $Name:         openvpn_usermanager.sh
# $Version:      v1.0
# $Author:       staugur
# $Create Date:  2018-10-17
# $Modify Date:  2018-10-30
# $Description:  OpenVPN用户添加(用户配置生成自动化)、吊销
#######################################################

# Shell Env
SHELL_DIR=$(cd $(dirname "$0") ; pwd)
# EASY_RSA目录
EASYRSA_HOME="/usr/local/src/openvpn-2.1_rc21/easy-rsa/2.0"
# OPENVPN配置目录
OPENVPN_CONF="/etc/openvpn"
# OPENVPN服务器IP
OPENVPN_SERVER_IP=""
# OPENVPN服务器监听端口
OPENVPN_SERVER_PORT=
# 服务器CA证书链
OPENVPN_SERVER_CRT="${OPENVPN_CONF}/ca.crt"
# 吊销的用户证书链
OPENVPN_SERVER_CRL="${OPENVPN_CONF}/crl.pem"
# 用户压缩包目录
USER_PACKAGEDIR="/tmp/openvpn-user-zips"
# 客户端软件
CLIENT_PACKAGFILE="https://static.saintic.com/download/thirdApp/OpenVPN/openvpn-install-2.3.6-I601-x86_64.exe"

#Write Log 
function show_err(){
    LOG_INFO=$@
    echo -e "\033[1;31m[ERROR] ${LOG_INFO}\033[0m"
}

function show_info(){
    LOG_INFO=$@
    echo -e "\033[1;32m[INFO] ${LOG_INFO}\033[0m"
}

# Shell Usage
shell_usage(){
    echo $"Usage: $0 {build|revoke} username"; exit 1
}

# Actual function
function build_user() {
    username=$1
    if [ ! -f $OPENVPN_SERVER_CRT ]; then
        echo "The ca.crt does not exist." ; exit 1
        return 1
    fi
    if [ -z $username ]; then
        echo "The user is null." ; exit 1
        return 1
    fi
    cd $EASYRSA_HOME
    [[ -f keys/${username}.crt || -f keys/${username}.key ]] && {
        echo "User ${username} already exist." ; exit 1
        return 1
    }

    which unix2dos > /dev/null 2>&1
    if [ "$?" != "0" ]; then
        yum -y install unix2dos dos2unix
    fi
    which unix2dos > /dev/null 2>&1
    [ "$?" != "0" ] && exit 1

    which wget > /dev/null 2>&1
    if [ "$?" != "0" ]; then
        yum install -y wget
    fi

    # 制作证书
    source ./vars > /dev/null 2>&1
    [ "$?" != "0" ] && exit 1

    export KEY_EMAIL="${username}@starokay.com"

    ./pkitool $username
    [ "$?" != "0" ] && exit 1

    /bin/cp -f keys/${username}.crt keys/${username}.key ${OPENVPN_CONF}
    [ "$?" != "0" ] && exit 1

    # 生成用户配置
    USER_TMP="$(date +%s)_tmp_${username}"
    mkdir $USER_TMP && cd $USER_TMP

    wget -c -O openvpn-install-2.3.6-I601-x86_64.exe ${CLIENT_PACKAGFILE}
    [ "$?" != "0" ] && exit 1

    # 配置文件
    conf="client.ovpn"
    cat > ${conf} <<EOF
client
dev tun
proto udp
remote $OPENVPN_SERVER_IP $OPENVPN_SERVER_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
#ca ca.crt
#cert ${username}.crt
#key ${username}.key
remote-cert-tls server
comp-lzo
verb 3
key-direction 1
EOF
    # 将证书私钥合并到配置文件中
    echo "<ca>" >> ${conf}
    cat ${OPENVPN_SERVER_CRT} >> ${conf}
    echo "</ca>" >> ${conf}
    echo "<cert>" >> ${conf}
    cat ${EASYRSA_HOME}/keys/${username}.crt >> ${conf}
    echo "</cert>" >> ${conf}
    echo "<key>" >> ${conf}
    cat ${EASYRSA_HOME}/keys/${username}.key >> ${conf}
    echo "</key>" >> ${conf}

    # 转换上述文件到windows格式
    unix2dos ${conf}
    [ "$?" != "0" ] && exit 1

    # 压缩
    zip -r ${username}.zip ./

    [ -d ${USER_PACKAGEDIR} ] || mkdir -p ${USER_PACKAGEDIR}

    mv ${username}.zip ${USER_PACKAGEDIR}
    [ "$?" != "0" ] && exit 1

    cd .. && rm -rf ${USER_TMP}

    service openvpn restart
    [ "$?" != "0" ] && exit 1

    # 打印下载链接
    echo -e "\033[32mBuild successfully, download with ${USER_PACKAGEDIR}/${username}.zip\033[0m"
}

function revoke_user() {
    username=$1
    if [ -z $username ]; then
        echo "The user is null."
        return 1
    fi
    cd $EASYRSA_HOME
    [[ ! -f keys/${username}.crt && ! -f keys/${username}.key ]] && {
        echo "User ${username} does not exist."
        return 1
    }
    # 吊销证书
    source ./vars > /dev/null 2>&1
    [ "$?" != "0" ] && exit 1

    export KEY_EMAIL="${username}@starokay.com"

    ./revoke-full ${username}

    /bin/cp -f keys/crl.pem ${OPENVPN_SERVER_CRL}
    [ "$?" != "0" ] && exit 1

    service openvpn restart
    [ "$?" != "0" ] && exit 1

    # 打印提示
    echo -e "\033[31mRevoke successfully, you should set openvpn server.conf with \"crl-verify ${OPENVPN_SERVER_CRL}\" and restart it.\033[0m"
    return 0
}

# Main Function
main(){
    # 判断脚本传参个数
    [ "$#" -ne 2 ] && {
        shell_usage
    }
    read -p "请确认是否执行\"$2 $1\", (Y/n, Default n):" en
    if [ "$en" != "Y" ]; then
        echo "Graceful Exit" ; exit 127
    fi
    case $1 in
        build)
            build_user $2
        ;;
        revoke)
            revoke_user $2
        ;;
        *)
            shell_usage
        ;;
    esac
}

#Exec
main $@