#!/bin/bash
read -p "请输入网站类型，支持httpd和nginx:" web
if [ "$web" == "httpd" ]; then
    echo "你选择的是httpd。"
else
    read -p "你选择的nginx，需要输入php-fpm的用户，即nginx运行的用户：" user
fi

PHP_VERSION=5.6.2
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"
CPU=$(grep "processor" /proc/cpuinfo | wc -l)
MEM=$(free -m | awk '/Mem:/{print $2}')
downloadlink="https://saintic.top/software"
clear
cat<<EOF
####################################################
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

CREATE_PHP() {
HEAD || ERROR
[ -f $lock ] && echo "Please run \"rm -f $lock\", then run again." && exit 1 || touch $lock
if [ -f $PACKAGE_PATH/php-${PHP_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/php-${PHP_VERSION} ] ; then
  rm -rf $PACKAGE_PATH/php-${PHP_VERSION}*
fi
rm -rf ${PACKAGE_PATH}/libmcrypt-*
rm -rf ${PACKAGE_PATH}/mcrypt-*
rm -rf ${PACKAGE_PATH}/mhash-*
yum -y remove php ; yum -y install tar bzip2 gzip libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel
cd $PACKAGE_PATH ; wget -c http://mirrors.sohu.com/php/php-${PHP_VERSION}.tar.gz
wget -c ${downloadlink}/web/php-lib.tar.gz|| echo "DownloadError,exit."&&exit 1
tar zxf php-lib.tar.gz
tar zxf libmcrypt-2.5.7.tar.gz
tar zxf mhash-0.9.2.tar.gz
tar zxf mcrypt-2.6.4.tar.gz
tar zxf php-${PHP_VERSION}.tar.gz
if [ `uname -p` == "x86_64" ]; then
  ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so &> /dev/null
  ln -s /usr/lib64/libpng.so /usr/lib/libpng.so &> /dev/null
fi
cd ${PACKAGE_PATH}/libmcrypt-2.5.7
./configure && make && make install
ln -s /usr/local/lib/libmcrypt.* /usr/lib64/
cd ${PACKAGE_PATH}/mhash-0.9.2
./configure && make && make install
ln -s /usr/local/lib/libmhash* /usr/lib64/
cd ${PACKAGE_PATH}/mcrypt-2.6.4
./configure && make && make install
cd ${PACKAGE_PATH}/php-$PHP_VERSION

if [ "$web" == "httpd" ]; then
./configure --prefix=${APP_PATH}/php --with-config-file-path=${APP_PATH}/php/etc/ --with-apxs2=${APP_PATH}/apache/bin/apxs --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext && make
make test <<EOF
n
EOF
make install
local LINE1=$(sed -i '/DirectoryIndex/ d' ${APP_PATH}/apache/conf/httpd.conf | grep -n -s -A 1 "IfModule dir_module" ${APP_PATH}/apache/conf/httpd.conf | grep ":" | awk -F : '{print $1}')
sed -i "${LINE1}a DirectoryIndex index.html index.php" ${APP_PATH}/apache/conf/httpd.conf
local LINE2=$(grep -n "<IfModule mime_module>" ${APP_PATH}/apache/conf/httpd.conf | grep ":" | awk -F : '{print $1}')
sed -i "${LINE2}a AddType application/x-httpd-php .php" ${APP_PATH}/apache/conf/httpd.conf
sed -i 's/DirectoryIndex/DirectoryIndex index.php index.htm/g' ${APP_PATH}/apache/conf/httpd.conf
elif [ "$web" == "nginx" ]; then
./configure --prefix=${APP_PATH}/php --with-config-file-path=${APP_PATH}/php/etc/ --with-mysql=mysqlnd --enable-fpm --with-mysqli=mysqlnd --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp --with-bz2 --enable-exif --with-gettext
make
make test <<EOF
n
EOF
make install
cd ${APP_PATH}/php/etc/ ; cp php-fpm.conf.default php-fpm.conf
sed -i "s@^pm.max_children.*@pm.max_children = $(($MEM/2/20))@" php-fpm.conf
sed -i "s@^pm.start_servers.*@pm.start_servers = $(($MEM/2/30))@" php-fpm.conf
sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($MEM/2/40))@" php-fpm.conf
sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($MEM/2/20))@" php-fpm.conf
sed -i "s/user = nobody/user = ${user}/g" php-fpm.conf
sed -i "s/group = nobody/group = ${user}/g" php-fpm.conf
sed -i 's#;pid = run\/php-fpm.pid#pid = run/php-fpm.pid#' php-fpm.conf
local init_fpm="${PACKAGE_PATH}/php-${PHP_VERSION}/sapi/fpm/init.d.php-fpm"
[ -e $init_fpm ] && cp $init_fpm /etc/init.d/php-fpm && chmod +x /etc/init.d/php-fpm && chkconfig --add php-fpm
fi
cp -f ${PACKAGE_PATH}/php-${PHP_VERSION}/php.ini-production ${APP_PATH}/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 10M/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' ${APP_PATH}/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' ${APP_PATH}/php/etc/php.ini
}

CREATE_PHP_API() {
if [ "$1" == "redis" ]; then    #php-redis client
local redis_api_version=2.2.7
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/redis-${redis_api_version}.tgz
tar zxf redis-${redis_api_version}.tgz ; cd redis-${redis_api_version}
${APP_PATH}/php/bin/phpize
./configure --enable-redis --with-php-config=${APP_PATH}/php/bin/php-config && make && make test && make install > /tmp/redis-api.txt
local EXT1=$(tail -1 /tmp/redis-api.txt | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT1}redis.so" >> ${APP_PATH}/php/etc/php.ini

elif [ "$1" = "mongodb" ]; then    #php-mongo client
local mongo_api_version=1.6.8
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/mongo-${mongo_api_version}.tgz
tar zxf mongo-${mongo_api_version}.tgz ; cd mongo-${mongo_api_version}
${APP_PATH}/php/bin/phpize
./configure --enable-mongo --with-php-config=${APP_PATH}/php/bin/php-config && make && make test && make install > /tmp/mongo-api
local EXT2=$(tail -1 /tmp/mongo-api | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT2}mongo.so" >> ${APP_PATH}/php/etc/php.ini

elif [ "$1" = "memcache" ]; then    #php-memcache client
local memcache_api_version=2.2.7
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/memcache-${memcache_api_version}.tgz
tar zxf memcache-${memcache_api_version}.tgz ; cd memcache-$memcache_api_version
${APP_PATH}/php/bin/phpize
./configure --enable-memcache --with-php-config=${APP_PATH}/php/bin/php-config --with-zlib-dir
make
make test <<EOF
n
EOF
make install > /tmp/memcache-api
local EXT3=$(tail -1 /tmp/memcache-api | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT3}memcache.so" >> ${APP_PATH}/php/etc/php.ini

elif [ "$1" = "memcached" ]; then    #php-memcached client
local memcached_api_version=2.2.0
cd $PACKAGE_PATH ; wget -c http://pecl.php.net/get/memcached-${memcached_api_version}.tgz
tar zxf memcached-${memcached_api_version}.tgz ; cd memcached-$memcached_api_version
${APP_PATH}/php/bin/phpize
./configure --enable-memcached --with-libmemcached-dir=/usr/local/libmemcached/ --with-php-config=${APP_PATH}/php/bin/php-config  --enable-memcached-json --disable-memcached-sasl
make
make test <<EOF
n
EOF
make install > /tmp/memcached-api
local EXT4=$(tail -1 /tmp/memcached-api | awk -F: '{print $2}' | awk '{print $1}')
echo "extension=${EXT4}memcached.so" >> ${APP_PATH}/php/etc/php.ini
fi
}


if [ "$web" == "httpd" ]; then
  :
elif [ "$web" == "nginx" ]; then
  [ -z $user ] && exit 1
  id -u $user &> /dev/null || useradd -M -s /sbin/nologin $user
fi

CREATE_PHP
[ -d ${APP_PATH}/php ] && rm -f $lock || echo "不存在PHP目录，安装失败，脚本退出" && exit 1
