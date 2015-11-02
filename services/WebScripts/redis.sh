#!/bin/bash
#author:saintic.com
#redis
REDIS_VERSION=3.0.4
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"

cat<<EOF
####################################################
##           程序版本请修改functions下各参数。    ##
##              若程序出错请查看错误信息。        ##
##作者信息:                                       ##
##    Author:   SaintIC                           ##
##    QQ：      1663116375                        ##
##    Phone:    18201707941                       ##
##    Design:   https://saintic.com/DIY           ##   
####################################################
EOF

function HEAD() {
  if [ $(id -u) != "0" ]; then
    echo "Error:make sure you are root!" ; exit 1
  fi
  sestatus &> /dev/null
  if [ $? -ne 0 ]; then
    yum -y install policycoreutils
  fi
  SESTATE=$(sestatus | nl | wc -l)
  if [ "$SESTATE" != "1" ]; then
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
  echo "Please disable SELinux."
  fi
  [ -d $PACKAGE_PATH ] || mkdir -p $PACKAGE_PATH
  [ -d $APP_PATH ] || mkdir -p $APP_PATH
}

function ERROR() {
  echo "Error:Please check this script and input/output!"
}

CREATE_REDIS_Interactive() {
if [ -f $PACKAGE_PATH/redis-${REDIS_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/redis-${REDIS_VERSION} ] ; then
  rm -rf $PACKAGE_PATH/redis-${REDIS_VERSION}*
fi
cd $PACKAGE_PATH ; wget -c http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz || wget -c https://codeload.github.com/antirez/redis/tar.gz/$REDIS_VERSION && mv $REDIS_VERSION redis-${REDIS_VERSION}.tar.gz
tar zxf redis-${REDIS_VERSION}.tar.gz ; cd redis-$REDIS_VERSION
make
make install
cd utils ; sh install_server.sh
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
sysctl -p
/etc/init.d/redis_6379 start
}

CREATE_REDIS_YES() {
if [ -f $PACKAGE_PATH/redis-${REDIS_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/redis-${REDIS_VERSION} ] ; then
  rm -rf $PACKAGE_PATH/redis-${REDIS_VERSION}*
fi
cd $PACKAGE_PATH ; wget -c http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz || wget -c https://codeload.github.com/antirez/redis/tar.gz/$REDIS_VERSION && mv $REDIS_VERSION redis-${REDIS_VERSION}.tar.gz
tar zxf redis-${REDIS_VERSION}.tar.gz ; cd redis-$REDIS_VERSION
make
cp -f src/redis-server src/redis-cli src/redis-check-dump src/redis-check-aof src/redis-benchmark /usr/bin/
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf ; sysctl -p
if [ $? -eq 0 ];then
  /usr/sbin/redis-server
  [ $? -eq 0 ] && exit 0 || exit 1
else
  echo "Maybe you are in a docker, please set the file '/etc/sysctl.conf'."
  exit 0
fi
}

api() {
local redis_api_version=2.2.7
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/redis-${redis_api_version}.tgz
tar zxf redis-${redis_api_version}.tgz ; cd redis-${redis_api_version}
${APP_PATH}/php/bin/phpize
./configure --enable-redis --with-php-config=${APP_PATH}/php/bin/php-config && make && make test && make install > /tmp/redis-api.txt
local EXT1=$(tail -1 /tmp/redis-api.txt | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT1}redis.so" >> ${APP_PATH}/php/etc/php.ini
}

REDIS() {
[ $exec_sh == "yes" ] && CREATE_REDIS_YES || CREATE_REDIS_Interactive
#api
}

if [[ $1 == '-y' ]];then
  exec_sh="yes"
else
  exec_sh="no"
fi
yum -y install wget tar gzip gcc gcc-c++

HEAD && REDIS || ERROR
#if need start aof, please modify redis.conf.

if [ `ps aux | grep -v grep | grep redis |wc -l` -ge 1 ]; then
  echo "Redis is OK, success!!!"
else
  echo "Redis haven't finished."
fi