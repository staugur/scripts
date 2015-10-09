#!/bin/bash
#Author:saintic.com
PACKAGE_PATH="/data/software"
APP_PATH="/data/app"
lock="/var/lock/subsys/paas.sdi.lock"
MYSQL_VERSION=5.5.20
downloadlink="https://saintic.top/software"

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

CREATE_MYSQL() {
[ -f $lock ] && echo "Please run \"rm -f $lock\", then run again." && exit 1 || touch $lock
yum -y install tar gzip bzip2 gcc gcc-c++ cmake ncurses-devel mysql wget
id -u mysql &> /dev/null || useradd -M -s /sbin/nologin mysql
if [ -f $PACKAGE_PATH/mysql-${MYSQL_VERSION}.tar.gz ] || [ -d $PACKAGE_PATH/mysql-${MYSQL_VERSION} ] ; then
  rm -rf $PACKAGE_PATH/mysql-${MYSQL_VERSION}*
fi
cd $PACKAGE_PATH ; wget -c http://down1.chinaunix.net/distfiles/mysql-${MYSQL_VERSION}.tar.gz || \
wget -c ${downloadlink}/web/mysql-${MYSQL_VERSION}.tar.gz ; tar zxf mysql-${MYSQL_VERSION}.tar.gz
cd mysql-$MYSQL_VERSION
cmake -DCMAKE_INSTALL_PREFIX=${APP_PATH}/mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all  -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=0 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=${APP_PATH}/mysql/data/ -DMYSQL_USER=mysql -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock -DMYSQL_TCP_PORT=3306 && make && make install
cp -f support-files/my-medium.cnf /etc/my.cnf
chown -R mysql:mysql ${APP_PATH}/mysql
${APP_PATH}/mysql/scripts/mysql_install_db --basedir=${APP_PATH}/mysql --datadir=${APP_PATH}/mysql/data --user=mysql
cp ${APP_PATH}/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
if [ $? -eq 0 ]; then
  echo -n "Start:/etc/init.d/mysqld start" ;
  /etc/init.d/mysqld start
else
  echo "Please check my.cnf"
fi
}

HEAD && CREATE_MYSQL || ERROR
if [ `ps aux | grep -v grep | grep mysqld |wc -l` -ge 1 ]; then
  echo "MySQL is OK, success!!!"
  rm -f $lock
else
  echo "MySQL haven't finished."
fi
