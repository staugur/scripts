FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&    yum -y install svn && svn export https://github.com/staugur/scripts/trunk/services/WebScripts/redis.sh && sh redis.sh -y
EXPOSE 6379
ENV LANG en_US.UTF-8
CMD  /usr/bin/redis-server && /bin/bash
