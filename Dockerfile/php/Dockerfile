FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum install -y php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt libmcrypt-devel php-fpm &&    sed -i "s/^listen =.*/listen = 0.0.0.0:9000/" /etc/php-fpm.d/www.conf
EXPOSE 9000
ENV LANG en_US.UTF-8
CMD /etc/init.d/php-fpm start && /bin/bash
