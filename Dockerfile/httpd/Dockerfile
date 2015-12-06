FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install httpd && mkdir -p /data/wwwroot ; ln -s /var/www/html /data/wwwroot
EXPOSE 80 443
ENV LANG en_US.UTF-8  
CMD /etc/init.d/httpd start && /bin/bash
