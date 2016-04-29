FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
ENV LANG en_US.UTF-8

WORKDIR /root

RUN yum -y install mysql-server mysql && \
    rm -rf /var/lib/mysql/test && \
    cp -f /usr/share/mysql/my-medium.cnf /etc/my.cnf

ADD entrypoint.sh /

ENTRYPOINT sh /entrypoint.sh && /bin/bash
