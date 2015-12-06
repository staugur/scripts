FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install resin &&     [ -d /data ] || mkdir /data && ln -sf /var/www/resin/ /data/wwwroot
EXPOSE 80 443
ENV LANG en_US.UTF-8  
CMD /etc/init.d/resin start && /bin/bash
