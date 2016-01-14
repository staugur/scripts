#!/bin/basha
TOMCAT_HOME=/data/tomcat
conf=${TOMCAT_HOME}/conf/server.xml

if [ -z $PORT ];then
    PORT=80
fi

http_port=$PORT
shutdown_port=$(($PORT + 10000))
sed -i 's/@shutdown-port@/'"${shutdown_port}"'/' $conf
sed -i 's/@http-port@/'"${http_port}"'/'         $conf

#sh ${TOMCAT_HOME}/bin/startup.sh
#Foreground output
sh ${TOMCAT_HOME}/bin/catalina.sh run 
