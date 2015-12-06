FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install subversion
EXPOSE 3690
ENV LANG en_US.UTF-8  
CMD /etc/init.d/svnserve start && /bin/bash
