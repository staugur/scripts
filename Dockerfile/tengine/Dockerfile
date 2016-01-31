FROM registry.saintic.com/base
MAINTAINER saintic.com <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    yum install -y svn && \
    svn export https://github.com/saintic/CoreWeb/trunk/create/tengine.sh && \
    sh tengine.sh && \
    [ -d /data ] || mkdir -p /data/wwwroot && rm -rf /data/app/tengine/html && \
    ln -sf /data/wwwroot /data/app/tengine/html
ENTRYPOINT nginx && bash
