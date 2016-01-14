FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>

#already install jdk 
#ADD jdk1.7.0_60 /usr/java/jdk1.7.0_60
#ENV JAVA_HOME /usr/java/jdk1.7.0_60
#ENV PATH $PATH:$JAVA_HOME/bin
#RUN mkdir -p "$JAVA_HOME"

ADD sspfront /data/tomcat
RUN mkdir -p /data/wwwroot && ln -s /data/wwwroot /data/tomcat/webapps/ROOT

ENTRYPOINT sh /data/tomcat/entrypoint.sh && /bin/bash
