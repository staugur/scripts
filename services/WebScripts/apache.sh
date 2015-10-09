#!/bin/bash
HTTPD_VERSION=2.2.29
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"
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

CREATE_HTTP() {
yum -y install tar bzip2 gzip libtool pcre-devel gcc-c++ gcc cmake make expat-devel zlib-devel neon-devel openssl-devel cyrus-sasl-devel wget
if [ -f $PACKAGE_PATH/httpd-${HTTPD_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/httpd-$HTTPD_VERSION ] ; then
  rm -rf $PACKAGE_PATH/httpd-${HTTPD_VERSION}*
fi
cd $PACKAGE_PATH
wget -c ${downloadlink}/web/Apache.zip
wget -c http://archive.apache.org/dist/httpd/httpd-${HTTPD_VERSION}.tar.gz
#1.Apr,Apr-util	
tar zxf apr-1.2.12.tar.gz
tar zxf apr-util-1.2.12.tar.gz
cd ${PACKAGE_PATH}/apr-1.2.12
./configure --enable-shared && make && make install
cd $PACKAGE_PATH/apr-util-1.2.12
./configure --enable-shared --with-expat=builtin --with-apr=/usr/local/apr/ && make && make install

cd ${PACKAGE_PATH} ; tar zxf httpd-${HTTPD_VERSION}.tar.gz ; cd httpd-${HTTPD_VERSION}
./configure --prefix=${APP_PATH}/apache --sysconfdir=/etc/httpd --enable-mods-shared=most --enable-modules=most --enable-so --enable-rewrite=shared --enable-ssl=shared --with-ssl --enable-cgi --enable-dav --with-included-apr --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr/bin/apu-1-config --enable-static-support --enable-charset-lite
make && make install
cp ${APP_PATH}/apache/bin/apachectl /etc/init.d/httpd
cat >> /etc/init.d/httpd <<EOF
#chkconfig:35 13 52
#description:Apache HTTP Server
EOF
chmod +x /etc/init.d/httpd
chkconfig --add httpd && chkconfig httpd on
sed -i "s/#ServerName www.example.com:80/ServerName www.saintic.com/g" /etc/httpd/httpd.conf
sed -i "s/ServerAdmin you@example.com/ServerAdmin admin@saintic.com/" /etc/httpd/httpd.conf
${APP_PATH}/apache/bin/apachectl -t
if [ $? -eq 0 ]; then
  /etc/init.d/httpd start
else
  echo "Please check httpd.conf"
fi
}

HTTPD() {
[ -f $lock ] && echo "Please run \"rm -f $lock\", then run again." && exit 1 || touch $lock
CREATE_HTTP
}

HEAD && HTTPD || ERROR

if [ `ps aux | grep -v grep | grep httpd |wc -l` -ge 1 ]; then
  rm -f $lock
else
  echo "Apache Httpd Server haven't finished."
fi

