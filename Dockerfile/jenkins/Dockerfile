FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#RUN yum -y install wget java-1.8.0-openjdk && wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo &&    #rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key &&    #yum -y install jenkins &&    #sed -i 's#^JENKINS_HOME=.*#JENKINS_HOME="/data/jenkins"#' /etc/sysconfig/jenkins &&    #sed -i 's#^JENKINS_USER=.*#JENKINS_USER="root"#' /etc/sysconfig/jenkins
    
RUN yum -y install wget java-1.8.0-openjdk && mkdir -p /data && cd /data/ ; wget -c http://ftp-chi.osuosl.org/pub/jenkins/war-stable/1.625.2/jenkins.war
EXPOSE 8080
ENV LANG en_US.UTF-8  
CMD cd /data && java -jar -DJENKINS_HOME=/data/jenkins jenkins.war && /bin/bash
