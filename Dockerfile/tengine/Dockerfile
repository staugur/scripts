FROM registry.saintic.com/base
MAINTAINER saintic.com <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&    yum install -y svn && svn export https://github.com/staugur/CoreWeb/trunk/create/tengine.sh ; sh tengine.sh &&     [ -d /data ] || mkdir /data && ln -s /data/app/tengine/html/ /data/wwwroot && rm -rf /data/software/
EXPOSE 80 443
ENV LANG en_US.UTF-8  
CMD /usr/sbin/nginx && /bin/bash
