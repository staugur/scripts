FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install tar gzip wget java-1.8.0-openjdk java;        wget -c http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63.tar.gz;        tar zxf apache-tomcat-7.0.63.tar.gz;        mv apache-tomcat-7.0.63 /usr/local/tomcat;        sed -i "s/<Connector port=\"8080\"/<Connector port=\"80\">/" /usr/local/tomcat/conf/server.xml;        mkdir -p /data/wwwroot ; ln -s /usr/local/tomcat/webapps/ROOT/ /data/wwwroot
EXPOSE 80
ENV LANG en_US.UTF-8
CMD /usr/local/tomcat/bin/startup.sh && /bin/bash
