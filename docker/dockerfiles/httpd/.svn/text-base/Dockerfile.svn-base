FROM registry.saintic.com/base

MAINTAINER SaintIC <staugur@saintic.com>  

RUN yum -y install httpd && mkdir -p /data/wwwroot

ENV LANG en_US.UTF-8

ADD entrypoint.sh /

ENTRYPOINT sh /entrypoint.sh && /bin/bash
