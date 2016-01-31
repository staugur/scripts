FROM registry.saintic.com/base
MAINTAINER saintic.com <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&    yum install -y svn && svn export https://github.com/staugur/CoreWeb/trunk/create/tengine.sh ; sh tengine.sh &&     [ -d /data ] || mkdir -p /data/wwwroot && ln -s /data/wwwroot /data/app/tengine/html/ && rm -rf /data/software/
EXPOSE 80
ENV LANG en_US.UTF-8  
CMD /usr/sbin/nginx && /bin/bash
