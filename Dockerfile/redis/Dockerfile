FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN yum -y install epel-release ; yum makecache ; yum -y install redis
EXPOSE 6379
ENV LANG en_US.UTF-8
CMD  /etc/init.d/redis start && /bin/bash
