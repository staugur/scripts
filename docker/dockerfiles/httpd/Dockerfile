#Apache Httpd Server
FROM registry.saintic.com/base

MAINTAINER SaintIC <staugur@saintic.com>  

ENV WEB_HOME /data/wwwroot
ENV LANG en_US.UTF-8

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    yum -y install httpd php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt libmcrypt-devel php-fpm sed php-xml && \
    [ -d $WEB_HOME ] || mkdir -p $WEB_HOME

ADD entrypoint.sh /

ENTRYPOINT sh /entrypoint.sh && /bin/bash
