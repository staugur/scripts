FROM registry.saintic.com/base
MAINTAINER SaintIC <staugur@saintic.com>  
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install passwd openssh-server && echo "123456"|passwd --stdin root &&    sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/' /etc/ssh/sshd_config;    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config;    sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config 
EXPOSE 22
ENV LANG en_US.UTF-8  
CMD /etc/init.d/sshd start && /bin/bash
