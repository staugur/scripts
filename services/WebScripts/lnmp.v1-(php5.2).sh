#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#My Home Page:http://www.saintic.com
clear
echo "运行此脚本将安装LNMP(Nginx-1.7.6，MySQL5.5.20，php5.2.17),请确保系统为CentOS6.X 64Bit Linux！"
echo "软件包均可在https://software.saintic.com中获得！"
echo "-----------------------------------------"
echo "重要参数说明:"
echo "    Nginx:ThinkPHP伪静态;"
echo "    MySQL:开启InnoDB事务引擎;"
echo "    PHP安装ZendOptimizer3.3.x模块且打补丁！"
echo "-----------------------------------------"
echo "MySQL根目录位于/usr/local/mysql/，配置文件是/etc/my.cnf,程序用户是mysql，服务名是mysqld。"
echo "PHP根目录位于/usr/local/php/，配置文件是/etc/php.ini和/usr/local/php/etc/php-fpm.conf。"
echo "Nginx根目录位于/usr/local/nginx/,配置文件是/usr/local/nginx/conf/nginx.conf，程序用户是nginx，服务名是nginx。"
echo "------------------------------------------"
echo "MySQL管理员root初始密码为空！"
echo "PHP信息: http://${HOSTNAME}/phpinfo.php"
echo "phpMyAdmin : http://${HOSTNAME}/phpmyadmin/"
echo "配置文件因需制宜，主要是nginx.conf,php-fpm.conf"
echo "------------------------------------------"
echo "作者:SaintIC,更多内容请访问http://script.saintic.com"
echo "------------------------------------------"
PACKAGE_PATH=/usr/src
downloadlink="https://saintic.top/software"
#下载软件
wget -c ${downloadlink}/web/lnmp.tar.gz
tar zxf lnmp.tar.gz -C $PACKAGE_PATH

#零：准备
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error:请确保以root用户执行此脚本！"
    exit 1
fi

#Disable SeLinux
if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

yum -y install patch libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel mysql wget vim unzip cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel libxslt-devel openldap-clients openldap-devel openldap sssd-ldap


#一：安装nginx
cd $PACKAGE_PATH
useradd -M -s /sbin/nologin  -u 80 nginx
tar zxf nginx-1.7.6.tar.gz
cd nginx-1.7.6
./configure --prefix=/usr/local/nginx --sbin-path=/usr/sbin/ --user=nginx --group=nginx  --with-poll_module  --with-file-aio  --with-http_ssl_module  --with-http_dav_module  --with-http_flv_module  --with-http_gzip_static_module --with-http_stub_status_module  --with-pcre
make && make install
nginx -t &> /dev/null
if [ $? = 0 ]
then
	nginx
else
	nginx -t && echo "Nginx web服务尚未启动！"
fi


#二：安装MySQL
useradd -M -s /sbin/nologin -u 27 mysql
cd $PACKAGE_PATH
tar zxf mysql-5.5.20.tar.gz &> /dev/null
cd mysql-5.5.20
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all  -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_DATADIR=/usr/local/mysql/data/ -DMYSQL_USER=mysql -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock -DMYSQL_TCP_PORT=3306 
make
make install
cp -f support-files/my-medium.cnf /etc/my.cnf &> /dev/null
chown -R mysql:mysql /usr/local/mysql &> /dev/null
ln -s  /usr/local/mysql/bin/* /usr/local/bin/
/usr/local/mysql/scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql &> /dev/null
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
/etc/init.d/mysqld start


#三：部署PHP
cd $PACKAGE_PATH
tar zxf libmcrypt-2.5.7.tar.gz
tar zxf mhash-0.9.2.tar.gz
tar zxf mcrypt-2.6.4.tar.gz 
tar jxf php-5.2.17.tar.bz2 
gzip -d php-5.2.17-fpm-0.5.14.diff.gz

ln -s /usr/lib64/libjpeg.so /usr/lib/libjpeg.so &> /dev/null
ln -s /usr/lib64/libpng.so /usr/lib/libpng.so &> /dev/null

cd $PACKAGE_PATH/libmcrypt-2.5.7
./configure && make && make install &> /dev/null
ln -s /usr/local/lib/libmcrypt.* /usr/lib64/

cd $PACKAGE_PATH/mhash-0.9.2
./configure && make && make install &> /dev/null
ln -s /usr/local/lib/libmhash* /usr/lib64/

cd $PACKAGE_PATH/mcrypt-2.6.4
./configure && make && make install &> /dev/null

cd $PACKAGE_PATH/php-5.2.17
patch -p1 < ../php-5.2.17-fpm-0.5.14.diff
./configure  --prefix=/usr/local/php --with-config-file-path=/etc --with-mysql=/usr/local/mysql/ --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-sysvsem --enable-sysvshm  --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext --enable-bcmath   --with-xsl  --enable-fastcgi  --enable-fpm 
make
make test <<EOF
n
EOF
make install 
cp -f php.ini-dist /etc/php.ini
ln -s /etc/php.ini /usr/local/php/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 10M/g' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini

/usr/local/php/sbin/php-fpm start
echo "/usr/local/php/sbin/php-fpm start" >> /etc/rc.local

#添加ZO模块
cd $PACKAGE_PATH
tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
cp -f ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/php/ &> /dev/null
echo '[Zend Optimizer]
zend_optimizer.optimization_level=15
zend_extension=/usr/local/php/ZendOptimizer.so'>> /etc/php.ini
echo 'export NGINX=/usr/local/nginx
export MYSQL=/usr/local/mysql
export PHP=/usr/local/php
export PATH=$PATH:$MYSQL/bin:$MYSQL/sbin:$PHP/sbin'>> /etc/profile
source /etc/profile
/etc/init.d/nginx reload &> /dev/null
/usr/local/php/sbin/php-fpm reload &> /dev/null

#phpMyAdmin
cd $PACKAGE_PATH
tar jxf phpMyAdmin-3.2.0-all-languages.tar.bz2
mv phpMyAdmin-3.2.0-all-languages /usr/local/nginx/html/phpmyadmin/
cp /usr/local/nginx/html/phpmyadmin/config.sample.inc.php /usr/local/nginx/html/phpmyadmin/config.inc.php 

#四：后续处理
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save &> /dev/null
echo "<?php
phpinfo();
?>"> /usr/local/nginx/html/phpinfo.php

nginx -t && echo $? &> /dev/null
if [ $? = "0" ]
	then
	echo "Nginx搭建完毕!"
	else
	echo "Nginx待测！"
fi

pgrep mysqld &> /dev/null
if [ $? = 0 ]
	then
	echo "MySQL搭建完毕！"
	else
	echo "MySQL待测！"
fi

