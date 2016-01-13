FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
ENV LANG en_US.UTF-8

WORKDIR /root

#RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
RUN yum -y install mysql-server mysql && \
    rm -rf /var/lib/mysql/testa

ADD entrypoint.sh /

EXPOSE 3306

ENTRYPOINT sh /entrypoint.sh && /bin/bash
