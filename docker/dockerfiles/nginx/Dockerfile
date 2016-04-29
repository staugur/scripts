#Nginx/Tengine + PHP(yum)
FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  

ENV LANG en_US.UTF-8
ENV WEB_HOME /data/wwwroot

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
    yum install -y nginx php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt libmcrypt-devel php-fpm sed && \
    [ -d $WEB_HOME ] || mkdir -p $WEB_HOME && \
    rm -rf /usr/share/nginx/html && \
    ln -sf $WEB_HOME /usr/share/nginx/html && \
    #sed -i "s/^listen =.*/listen = 127.0.0.1:9000/" /etc/php-fpm.d/www.conf
    #sed -i "s/^listen.allowed_clients =.*/listen.allowed_clients = 0.0.0.0:9000/" /etc/php-fpm.d/www.conf    
    sed -i "s/^user =.*/user = nginx/"    /etc/php-fpm.d/www.conf && \
    sed -i "s/^group =.*/group = nginx/"  /etc/php-fpm.d/www.conf

ADD nginx.conf /etc/nginx/
ADD entrypoint.sh /

ENTRYPOINT sh /entrypoint.sh && /bin/bash
