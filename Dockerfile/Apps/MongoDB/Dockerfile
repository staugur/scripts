#docker.io/staugur/base
FROM staugur/base

MAINTAINER SaintIC <staugur@saintic.com>  

RUN yum -y install svn;svn export https://github.com/staugur/scripts/trunk/services/WebScripts/mongo.sh;sh mongo.sh

RUN sed -i "s/^bind_ip.*/bind_ip = 0.0.0.0/" /data/app/mongodb/mongod.conf

EXPOSE 27017

ENV LANG en_US.UTF-8  

CMD /data/app/mongodb/bin/mongod -f /data/app/mongodb/mongod.conf ; /bin/bash
