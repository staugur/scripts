#Nginx/Tengine + PHP(yum)
FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  

ENV LANG en_US.UTF-8
ENV WEB_HOME /data/wwwroot

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    yum install -y svn php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt libmcrypt-devel php-fpm sed && \
    svn export https://github.com/saintic/CoreWeb/trunk/create/tengine.sh && \
    sh tengine.sh && \
    [ -d $WEB_HOME ] || mkdir -p $WEB_HOME && rm -rf /data/app/tengine/html && \
    ln -sf $WEB_HOME /data/app/tengine/html && \
    sed -i "s/^user =.*/user = www/"    /etc/php-fpm.d/www.conf && \
    sed -i "s/^group =.*/group = www/"  /etc/php-fpm.d/www.conf

ADD nginx.conf /data/app/tengine/conf/
ADD entrypoint.sh /

ENTRYPOINT sh /entrypoint.sh && /bin/bash
