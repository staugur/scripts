#!/bin/bash
#Author:saintic.com
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

MongoConfig() {
mkdir -p ${APP_PATH}/mongodb/data ; touch ${APP_PATH}/mongodb/mongod.log
cat > ${APP_PATH}/mongodb/mongod.conf<<EOF
systemLog:
   destination: file
   path: "${APP_PATH}/mongodb/mongod.log"
   logAppend: true
storage:
   dbPath: "${APP_PATH}/mongodb/data"
   journal:
      enabled: true
   engine: wiredTiger
   mmapv1:
      journal:
         commitIntervalMs: 100
   wiredTiger:
      engineConfig:
         cacheSizeGB: 1
         statisticsLogDelaySecs: 1
processManagement:
   fork: true
net:
   bindIp: 0.0.0.0
   port: 27017
setParameter:
   enableLocalhostAuthBypass: false
EOF
}

CREATE_MONGODB() {
yum -y install wget tar gzip
cd $PACKAGE_PATH
if [ -f $PACKAGE_PATH/mongodb-linux-x86_64-3.0.3.tgz ] || [ -d $PACKAGE_PATH/mongodb-linux-x86_64-3.0.3 ] ; then
  rm -rf $PACKAGE_PATH/mongodb-linux-x86_64-3.0.3*
fi
if [ `uname -p` == "x86_64" ]; then
wget -c https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.3.tgz
tar zxf mongodb-linux-x86_64-3.0.3.tgz ; mv mongodb-linux-x86_64-3.0.3 ${APP_PATH}/mongodb
else
wget -c https://fastdl.mongodb.org/linux/mongodb-linux-i686-3.0.3.tgz
tar zxf mongodb-linux-i686-3.0.3.tgz ; mv mongodb-linux-i686-3.0.3 ${APP_PATH}/mongodb
fi
MongoConfig
ln -s ${APP_PATH}/mongodb/bin/* /usr/bin/
mongod -f ${APP_PATH}/mongodb/mongod.conf &
}

api() {
local mongo_api_version=1.6.8
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/mongo-${mongo_api_version}.tgz
tar zxf mongo-${mongo_api_version}.tgz ; cd mongo-${mongo_api_version}
${APP_PATH}/php/bin/phpize
./configure --enable-mongo --with-php-config=${APP_PATH}/php/bin/php-config && make && make test && make install > /tmp/mongo-api
local EXT2=$(tail -1 /tmp/mongo-api | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT2}mongo.so" >> ${APP_PATH}/php/etc/php.ini
}

MONGO() {
CREATE_MONGODB
#api
}

HEAD && MONGO || ERROR
if [ `ps aux | grep -v grep | grep mongo |wc -l` -ge 1 ]; then
  echo "MongoDB is OK, success!!!"
  echo "${APP_PATH}/mongodb/bin/mongod -f ${APP_PATH}/mongodb/mongod.conf &" >> /etc/rc.local
else
  echo "MongoDB haven't finished."
fi

