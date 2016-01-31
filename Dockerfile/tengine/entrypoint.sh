#!/bin/bash

if [ -z $WEB_HOME ];then
    echo "No WEB_HOME Environment!"
    exit 1
else
   if [ ! -d $WEB_HOME ];then
       echo 'No $WEB_HOME Directory!'
       exit 1
   fi
fi
sed -i 's#@WEB_HOME@#'"${WEB_HOME}"'#' /data/app/tengine/conf/nginx.conf
/usr/sbin/nginx
/etc/init.d/php-fpm start
