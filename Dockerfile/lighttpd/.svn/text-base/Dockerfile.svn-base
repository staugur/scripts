FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum -y install tar pcre-devel wget gzip bzip2 bzip2-devel gcc gcc-c++ zlib-devel openssl-devel; wget -c http://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.37.tar.gz &&    tar zxf lighttpd-1.4.37.tar.gz && cd lighttpd-1.4.37 &&    ./configure --prefix=/data/app/lighttpd --sysconfdir=/etc/lighhtpd --htmldir=/data/wwwroot --sbindir=/usr/sbin && make && make install &&    [ -d /data/wwwroot ] || mkdir /data/wwwroot
EXPOSE 80 443
ENV LANG en_US.UTF-8  
CMD lighttpd && /bin/bash
