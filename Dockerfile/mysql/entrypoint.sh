#!/bin/bash

/etc/init.d/mysqld start

if [ -z $MY_USER ]; then
    MY_USER=root
    MY_PASSSWD=123456
fi

mysql -uroot -e "grant all privileges on *.* to \"${MY_USER}\"@'%' identified by \"${MY_PASSWD}\" with grant option;"
mysql -uroot -e "grant all privileges on *.* to \"${MY_USER}\"@'localhost' identified by \"${MY_PASSWD}\" with grant option;"

#mysql -uroot -e "grant all privileges on *.* to '"${MY_USER}"@"%"' identified by \"${MY_PASSWD}\" with grant option;"

#mysql -uroot -e "grant all privileges on *.* to '"${MY_USER}"@"localhost"' identified by \"${MY_PASSWD}\" with grant option;"

/etc/init.d/mysqld restart

sleep 5
