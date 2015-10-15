# This is a base comment  
FROM staugur/base

MAINTAINER SaintIC <staugur@saintic.com>  
  
RUN yum -y install svn;svn export https://github.com/staugur/scripts/trunk/services/WebScripts/redis.sh;sh redis.sh

EXPOSE 6379

ENV LANG en_US.UTF-8

CMD /etc/init.d/redis start&&/bin/bash
