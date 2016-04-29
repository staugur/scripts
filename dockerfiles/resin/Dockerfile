FROM registry.saintic.com/base
MAINTAINER saintic <staugur@saintic.com>

#already install jdk 
#ADD jdk1.7.0_60 /usr/java/jdk1.7.0_60
#ENV JAVA_HOME /usr/java/jdk1.7.0_60
#ENV PATH $PATH:$JAVA_HOME/bin
#RUN mkdir -p "$JAVA_HOME"

RUN mkdir /data

ADD resin4.0.34 /data/

EXPOSE 8088

ENTRYPOINT /bin/bash
