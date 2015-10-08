#/bin/bash
NGINX_VERSION=1.8.0
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"
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


CREATE_NGINX() {
HEAD || ERROR
id -u www &> /dev/null || useradd -M -s /sbin/nologin www
if [ -f $PACKAGE_PATH/nginx-${NGINX_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/nginx-$NGINX_VERSION ] ; then
  rm -rf $PACKAGE_PATH/nginx-${NGINX_VERSION}*
fi
yum -y install tar bzip2 gzip pcre pcre-devel gcc gcc-c++ zlib-devel wget openssl-devel ; cd $PACKAGE_PATH ; wget -c http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && tar zxf nginx-${NGINX_VERSION}.tar.gz && cd nginx-$NGINX_VERSION
./configure --prefix=${APP_PATH}/nginx --user=www --group=www --with-poll_module  --with-http_ssl_module --with-http_gzip_static_module --with-http_stub_status_module --with-http_realip_module --with-pcre && make && make install
${APP_PATH}/nginx/sbin/nginx -t &> /dev/null
ln -s ${APP_PATH}/nginx/sbin/nginx /usr/sbin/nginx
if [ $? -eq 0 ]; then
  echo "Start:/usr/sbin/nginx" ; /usr/sbin/nginx
  echo "${APP_PATH}/nginx/sbin/nginx" >> /etc/rc.local
else
  echo "Please check nginx.conf"
fi
rm -f $lock
}

NGINX() {
[ -f $lock ] && echo "Please run \"rm -f $lock\", then run again." && exit 1 || touch $lock
CREATE_NGINX
}

HEAD && NGINX || ERROR

if [ `ps aux | grep -v grep | grep nginx |wc -l` -ge 1 ]; then
  rm -f $lock
else
  echo "Nginx haven't finished."
fi
