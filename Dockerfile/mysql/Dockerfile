FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
ENV LANG en_US.UTF-8
ENV PASSWD 123456
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install mysql-server mysql &&        /etc/init.d/mysqld start &&        mysql -e "grant all privileges on *.* to 'root'@'%' identified by \"\";" &&        mysql -e "grant all privileges on *.* to 'root'@'localhost' identified by \"\";"&&        rm -rf /var/lib/mysql/test;
EXPOSE 3306
CMD /etc/init.d/mysqld start && /bin/bash
