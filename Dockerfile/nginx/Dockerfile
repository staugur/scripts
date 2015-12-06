FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&    rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm &&    yum install -y nginx &&     [ -d /data ] || mkdir /data ; ln -s /usr/share/nginx/html/ /data/wwwroot
EXPOSE 80 443
ENV LANG en_US.UTF-8  
CMD /etc/init.d/nginx start && /bin/bash
