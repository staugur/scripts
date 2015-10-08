#!/bin/bash
#create tomcat server

#jdk1.8
yum -y install java-1.8.0-openjdk java
#tomcat 1.8
cd /usr/src
wget -c http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63.tar.gz
tar zxf apache-tomcat-7.0.63.tar.gz
mv apache-tomcat-7.0.63 /usr/local/tomcat
/usr/local/tomcat/bin/startup.sh
echo "/usr/local/tomcat/bin/startup.sh" >> /etc/rc.local
