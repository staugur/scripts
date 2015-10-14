# This is a base comment  
FROM staugur/centos
MAINTAINER SaintIC <staugur@saintic.com>  
  
#yum install Package
ADD redis.sh .
RUN sh redis.sh
ADD supervisord.conf /etc/supervisord.conf
#set port 
EXPOSE 6379

#set ENV
ENV LANG en_US.UTF-8
ENV LC_ALL C

#run supervisor  
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf &> /dev/null &"]

