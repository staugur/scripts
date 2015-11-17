#!/bin/bash
#nginx+keepalived
if [ $(id -u) != "0" ]; then
  echo "Error:请确保以root用户执行此脚本！" ; exit 1
fi

function download() {
  cd ${soft_dir};
  wget -c http://www.keepalived.org/software/keepalived-${ha_version}.tar.gz
}

function master() {
cat > keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
   router_id nginx_master
}
vrrp_script Monitor_Nginx {
   script "/usr/local/nginx_pid.sh"
   interval 2
   weight -10
}
vrrp_instance nginx {
    state MASTER
    interface ${dev}
    virtual_router_id 99
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        $vip
    }
    track_script {
        Monitor_Nginx
    }
}
EOF
}

function backup() {
cat > keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
   router_id nginx_backup
}
vrrp_script Monitor_Nginx {
   script "/usr/local/nginx_pid.sh"
   interval 2
   weight -10
}
vrrp_instance nginx {
    state BACKUP
    !state MASTER
    interface ${dev}
    virtual_router_id 99
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        $vip
    }
    track_script {
        Monitor_Nginx
    }
}
EOF
}

function keepalived_check_nginx() {
cat > /usr/local/nginx_pid.sh<<"EOF"
#!/bin/bash
A=`ps -C nginx --no-header |wc -l`
if [ $A -eq 0 ];then   
    nginx ; sleep 1
    if [ `ps -C nginx --no-header |wc -l` -eq 0 ];then
        service keepalived stop
    fi
fi
EOF
chmod +x /usr/local/nginx_pid.sh
}

function keepalived() {
  #install keepalived and configure
  cd ${soft_dir}
  [ -d keepalived-${ha_version} ] && rm -rf keepalived-${ha_version}
  tar zxf keepalived-${ha_version}.tar.gz ; cd keepalived-${ha_version}
  ./configure --prefix=${app_dir}/keepalived --sysconf=/etc && make && make install
  cd ${ha_conf}; mv keepalived.conf keepalived.conf.bak
  if [ "$ha_type" == "master" ];then
    master
  elif [ "$ha_type" == "backup" ];then
    backup
  fi
  keepalived_check_nginx
  ln -s ${app_dir}/keepalived/sbin/keepalived /usr/sbin/
  /etc/init.d/keepalived start
}

function iptables_rule() {
  iptables -I INPUT -p ip -d 224.0.0.18 -j ACCEPT
  #iptables -I OUTPUT -o ${dev} -d 224.0.0.18 -j ACCEPT
  #iptables -I OUTPUT -o ${dev} -s 224.0.0.18 -j ACCEPT
  #iptables -I INPUT -i ${dev} -d 224.0.0.18 -j ACCEPT
  #iptables -I INPUT -i ${dev} -s 224.0.0.18 -j ACCEPT
}

#script start
if [ $# -ne 2 ];then
  echo "Error:需要两个类型参数,$0 master/backup virtual_ip";
  echo '如果需要安装Nginx服务，请执行"curl -s https://saintic.top/nginx.txt > nginx.sh && sh nginx.sh"'
  exit 1
fi
#modify version and other info
ha_version="1.2.17"
ha_conf="/etc/keepalived"
app_dir="/data/app"
soft_dir="/data/software"
ha_type=$1
vip=$2
dev="eth0"   #your network interface device
#check ip format
_check_ip=`echo $vip | egrep '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'`
[ ! $_check_ip ] && echo "IP地址格式不正确" && exit 3
[ -d ${soft_dir} ] || mkdir -p ${soft_dir}
[ -d ${app_dir} ] || mkdir -p ${app_dir}
yum -y install tar gzip wget gcc gcc-c++ make openssl-devel curl
[ -f ${soft_dir}/keepalived-${ha_version}.tar.gz ] || download
nginx
keepalived
iptables_rule
