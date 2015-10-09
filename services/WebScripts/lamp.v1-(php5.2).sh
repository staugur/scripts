#!/bin/bash
#Author:SaintIC
#Notes:转载请注明出处！
#My Home Page:http://www.saintic.com
clear
echo "运行此脚本将安装LAMP(Apache2.2.29，MySQL5.5.20，php5.2.17)，请确保系统为CentOS6.x 64Bit Linux！"
echo "软件包均可在https://software.saintic.com中获得！"
echo "-----------------------------------------"
echo "重要参数说明:"
echo "    Apache:开启伪静态;"
echo "    MySQL:开启InnoDB存储引擎;"
echo "    PHP安装ZendOptimizer3.3.x模块！"
echo "-----------------------------------------"
echo "Apache根目录位于/usr/local/apache/,配置文件是/etc/httpd/httpd.conf，程序用户是daemon，服务名是httpd。"
echo "MySQL根目录位于/usr/local/mysql/，配置文件是/etc/my.cnf,程序用户是mysql，服务名是mysqld。"
echo "PHP根目录位于/usr/local/php/，配置文件是/etc/php.ini。"
echo "------------------------------------------"
echo "MySQL管理员root密码为空！"
echo "PHP信息: http://${HOSTNAME}/phpinfo.php"
echo "phpMyAdmin : http://${HOSTNAME}/phpmyadmin/"
echo "------------------------------------------"
echo "作者:SaintIC,更多内容请访问http://script.saintic.com"
echo "------------------------------------------"
PACKAGE_PATH=/usr/src
downloadlink="https://saintic.top/software"
#下载软件
wget -c ${downloadlink}/web/lamp.tar.gz
tar zxf lamp.tar.gz -C $PACKAGE_PATH

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


yum -y install libxml2-devel libtool pcre-devel ncurses-devel bison-devel gcc-c++ gcc make cmake expat-devel zlib-devel gd-devel libcurl-devel bzip2-devel readline-devel libedit-devel perl neon-devel openssl-devel mysql wget telnet unzip cyrus-sasl-devel php-mbstring php-bcmath gettext-devel curl-devel libjpeg-devel libpng-devel openldap-clients openldap-devel openldap sssd-ldap
	
	
#一：安装Apache
#1.Apr,Apr-util
cd $PACKAGE_PATH
tar zxf apr-1.2.12.tar.gz  &> /dev/null
cd apr-1.2.12	
./configure --enable-shared && make && make install &> /dev/null

cd $PACKAGE_PATH
tar zxf apr-util-1.2.12.tar.gz &> /dev/null
cd apr-util-1.2.12
./configure --enable-shared --with-expat=builtin --with-apr=/usr/local/apr/ && make && make install &> /dev/null

#2.Apache
cd $PACKAGE_PATH
tar zxf httpd-2.2.29.tar.gz &> /dev/null
cd httpd-2.2.29
./configure  --prefix=/usr/local/apache/ --sysconfdir=/etc/httpd --enable-mods-shared=most --enable-modules=most --enable-so --enable-rewrite=shared --enable-ssl=shared --with-ssl --enable-cgi --enable-dav --with-included-apr   --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr/bin/apu-1-config --enable-static-support --enable-charset-lite --enable-static-ab --enable-maintainer-mode 
make
make install

cp /usr/local/apache/bin/apachectl /etc/init.d/httpd 
echo "#chkconfig:2345 13 52" >> /etc/init.d/httpd
echo "#description:Apache HTTP Server" >> /etc/init.d/httpd
chkconfig --add httpd
chkconfig httpd on
#这个sed和awk需添加说明注释
sed -i 's/#ServerName www.example.com:80/ServerName localhost/g' /etc/httpd/httpd.conf

ln -s  /usr/local/apache/bin/* /usr/local/bin/
/usr/local/apache/bin/apachectl -t && echo $? &> /dev/null
if [ $? = 0 ]
then
	/usr/local/apache/bin/apachectl start && echo "已经启动httpd服务！"
else
	/usr/local/apache/bin/apachectl -t
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
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-apxs2=/usr/local/apache/bin/apxs --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --enable-xml --enable-sysvsem --enable-sysvshm  --enable-inline-optimization --with-curl --enable-mbstring --with-mhash --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --enable-sockets --with-pdo-mysql --enable-pdo --enable-zip --enable-soap --enable-ftp  --enable-shmop --with-bz2 --enable-exif --with-gettext --disable-debug
make
make test <<EOF
n
EOF
make install 
cp php.ini-dist /usr/local/php/etc/php.ini
rm -rf /etc/php.ini &> /dev/null
ln -s /usr/local/php/etc/php.ini /etc &> /dev/null
sed -i 's/post_max_size = 8M/post_max_size = 10M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/DirectoryIndex/DirectoryIndex index.php/g' /etc/httpd/httpd.conf

#添加ZO模块
cd $PACKAGE_PATH
tar zxf ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz
cp -f ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp/ZendOptimizer.so /usr/local/php/ &> /dev/null
echo "[Zend Optimizer]
zend_optimizer.optimization_level=15
zend_extension=/usr/local/php/ZendOptimizer.so">> /etc/php.ini

echo 'export APACHE=/usr/local/apache
export MYSQL=/usr/local/mysql
export PHP=/usr/local/php
export PATH=$PATH:$APACHE/bin:$MYSQL/bin:$MYSQL/sbin:$PHP/bin:$PHP/sbin'>> /etc/profile
source /etc/profile

#phpMyAdmin
cd $PACKAGE_PATH
tar jxf phpMyAdmin-3.2.0-all-languages.tar.bz2
mv phpMyAdmin-3.2.0-all-languages /usr/local/apache/htdocs/phpmyadmin/
cp /usr/local/apache/htdocs/phpmyadmin/config.sample.inc.php /usr/local/apache/htdocs/phpmyadmin/config.inc.php 

#四：后续处理
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save &> /dev/null
echo "<?php
phpinfo();
?>"> /usr/local/apache/htdocs/phpinfo.php

apachectl -t && echo $? &> /dev/null
if [ $? = 0 ]
	then
	echo "Apache搭建完毕!"
	else
	echo "Apache待测！"
fi

pgrep mysqld &> /dev/null
if [ $? = 0 ]
	then
	echo "MySQL搭建完毕！"
	else
	echo "MySQL待测！"
fi





 
 