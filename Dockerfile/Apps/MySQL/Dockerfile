# This is a base comment  
FROM staugur/base
MAINTAINER SaintIC <staugur@saintic.com>  

RUN yum -y install subversion;svn export https://github.com/staugur/scripts/trunk/services/WebScripts/mysql.sh;sh mysql.sh

EXPOSE 3306

ENV LANG en_US.UTF-8

CMD /etc/init.d/mysqld start && /bin/bash
