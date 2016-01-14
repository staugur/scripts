FROM registry.saintic.com/base

MAINTAINER SaintIC <staugur@saintic.com>  

RUN yum -y install httpd && mkdir -p /data/wwwroot && ln -s /data/wwwroot /var/www/html

EXPOSE 80

ENV LANG en_US.UTF-8  

ENTRYPOINT /etc/init.d/httpd start && /bin/bash
