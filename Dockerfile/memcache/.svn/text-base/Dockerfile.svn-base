FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install memcached
EXPOSE 11211
ENV LANG en_US.UTF-8  
CMD /usr/bin/memcached -d -u root && /bin/bash
