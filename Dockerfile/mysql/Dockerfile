FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
ENV LANG en_US.UTF-8
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    yum -y install mysql-server mysql && \
    rm -rf /var/lib/mysql/test
COPY start /
EXPOSE 3306
CMD /start && /bin/bash
