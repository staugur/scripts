#!/bin/bash
#@Author:saintic
#@Description:Monitor sphinx,php-fpm

#sphinx coreseek:9306,9312
SPHINX="/usr/local/coreseek"
SPHINX_EXEC="${SPHINX}/bin/searchd"
SPHINX_ERROR="/tmp/sphinx.err.txt"
[ -f $SPHINX_ERROR ] && rm -f $SPHINX_ERROR || touch $SPHINX_ERROR
SPHINX_PORT=`netstat -anptl | grep searchd | wc -l`
if [ "$SPHINX_PORT" != "2" ]
then
  if [ -e ${SPHINX}/var/log/searchd.pid ]; then
        pid=`${SPHINX}/var/log/searchd.pid`
	echo "Sphinx($pid) is running, but not ports for two!" | mailx -s "SOA:Sphinx,Only Ports." -r monitor@yunjiazheng.com stagur@qq.com
  else 
	$SPHINX_EXEC &>> $SPHINX_ERROR
	echo "SOA:Sphinx is down.Please check it quickly." | mailx -s "SOA:Report:Sphinx Alarm"  -r monitor@yunjiazheng.com -a ${SPHINX_ERROR} -c taochengwei@yunjiazheng.com legends.zqs@qq.com,yuanxiaoming@yunjiazheng.com,staugur@qq.com
  fi
fi

#SOA:php-fpm.5.6:9000
PHP_YAY="/usr/local/php"
PHP_YAY_EXEC="${PHP_YAY}/sbin/php-fpm"

PHP_ERROR="/tmp/php.err.txt"
[ -f $PHP_ERROR ] && rm -f $PHP_ERROR || touch $PHP_ERROR
netstat -anptl |  grep LISTEN | grep php-fpm &>> $PHP_ERROR
grep "9000" $PHP_ERROR
if [ $? != "0" ]; then
	${PHP_YAY_EXEC} 2>> $PHP_ERROR
    echo "SOA:PHP5.6.2 is down.Please check it quickly." | mailx -s "SOA Report:PHP5.6.2 Alarm"  -r monitor@yunjiazheng.com -a ${PHP_ERROR} -c taochengwei@yunjiazheng.com yuanxiaoming@yunjiazheng.com,legends.zqs@qq.com,staugur@qq.com
fi
