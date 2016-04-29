FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&     yum -y install svn && svn export https://github.com/staugur/CoreWeb/trunk/create/mongodb.sh &&     sed -i 's#mongod -f /etc/mongod.conf &##' mongodb.sh && sh mongodb.sh &&     ln -sf /data/app/mongodb/mongod.conf /etc/mongod.conf &&     sed -i "s/engine: wiredTiger/engine: mmapv1/" /etc/mongod.conf
EXPOSE 27017
ENV LANG en_US.UTF-8  
CMD /usr/bin/mongod -f /etc/mongod.conf && /bin/bash
