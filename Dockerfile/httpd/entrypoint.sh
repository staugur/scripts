#!/bin/bash
conf=/etc/httpd/conf/httpd.conf

if [ -z $PORT ];then
    PORT=80
fi
if [ -z $WEB_HOME ];then
    WEB_HOME=/data/wwwroot
fi

if [ -z $EMAIL ];then
    EMAIL=root@localhost
fi

sed -i 's/^Listen.*/Listen '"${PORT}"'/'                  $conf
sed -i 's#^DocumentRoot.*#DocumentRoot '"${WEB_HOME}"'#'  $conf
sed -i 's/^ServerAdmin.*/ServerAdmin '"${EMAIL}"'/'       $conf
sed -i 's/^#ServerName.*/ServerName localhost/'           $conf

cat >> $conf <<EOF
<Directory "${WEB_HOME}">
    Options Indexes FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
EOF

if [ $? -ne 0 ] ;then
    echo "ENTRYPOINT ERROR"
    exit 1
fi

/etc/init.d/httpd start
/etc/init.d/php-fpm start
