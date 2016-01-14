#!/bin/bash
conf=/etc/httpd/conf/httpd.conf

if [ -z $PORT ];then
    PORT=80
fi
if [ -z $CODE_ROOT ];then
    CODE_ROOT=/data/wwwroot
fi

if [ -z $EMAIL ];then
    EMAIL=root@localhost
fi

sed -i 's/^Listen.*/Listen '"$PORT"'/'          $conf
sed -i 's/^DocumentRoot.*/'"${CODE_ROOT}"'/'    $conf
sed -i 's/^ServerAdmin.*/'"${EMAIL}"'/'         $conf
sed -i 's/^#ServerName.*/ServerName localhost/' $conf

cat >> $conf <<EOF
<Directory '"${CODE_ROOT}"'>
    Options Indexes FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
EOF

/etc/init.d/httpd start
