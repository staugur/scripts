#!/bin/bash

/etc/init.d/mysqld start
mysql -uroot -e "DROP DATABASE test;"

[ -z $MY_USER ] && exit 1
[ -z $MY_PASSWD ] && exit 1

#mysql -uroot -e "grant all privileges on *.* to \"${MY_USER}\"@'%' identified by \"${MY_PASSWD}\" with grant option;"
#mysql -uroot -e "grant all privileges on *.* to \"${MY_USER}\"@'localhost' identified by \"${MY_PASSWD}\" with grant option;"

mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* to \"${MY_USER}\"@'%' IDENTIFIED BY \"${MY_PASSWD}\" WITH GRANT OPTION;"

/etc/init.d/mysqld restart

sleep 5
