FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
ENV LANG en_US.UTF-8 
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&    rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm &&    yum install -y nginx && mkdir -p /data && ln -s /usr/share/nginx/html/ /data/wwroot
RUN yum install -y php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring &&     yum install -y php-mcrypt php-bcmath php-mhash libmcrypt libmcrypt-devel php-fpm
EXPOSE 80 
CMD /etc/init.d/nginx start && /etc/init.d/php-fpm start && /bin/bash
