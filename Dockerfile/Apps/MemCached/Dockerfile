#docker.io/staugur/base
FROM staugur/base

MAINTAINER SaintIC <staugur@saintic.com>  

RUN yum -y install memcached

EXPOSE 11211

ENV LANG en_US.UTF-8  

CMD /usr/bin/memcached -d -u root;/bin/bash
