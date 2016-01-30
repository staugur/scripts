#!/bin/bash
#Create virtual ftp users, first user is test
error() {
  echo "Error,args is 2:user password" 
  exit 1
}
SYS_VERSION=$(awk -F "release" '{print $2}' /etc/redhat-release | awk '{print $1}' | awk -F . '{print $1}')
[ "$#" = "2" ] || error
vfu=/etc/vsftpd/vfu.list
vfudb=/etc/vsftpd/vfu.db
vfudir=/etc/vsftpd/vfu_dir
user=$1
passwd=$2

yum -y install vsftpd ftp
[ "$SYS_VERSION" == "5" ] && yum -y install db4-utils
[ "$SYS_VERSION" == "6" ] && yum -y install db4-utils
[ "$SYS_VERSION" == "7" ] && yum -y install libdb-utils
cat >> $vfu <<EOF
$user
$passwd
EOF
db_load -T -t hash -f $vfu $vfudb
chmod 600 $vfu $vfudb

cat > /etc/pam.d/vsftpd.vu <<EOF
#%PAM-1.0
auth   required     pam_userdb.so  db=/etc/vsftpd/vfu
account required    pam_userdb.so  db=/etc/vsftpd/vfu
EOF

mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
cat > /etc/vsftpd/vsftpd.conf<<EOF
ftpd_banner=SDI CodeSourceRoot.
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
xferlog_enable=YES
xferlog_std_format=YES
xferlog_file=/var/log/vsftpd.log
userlist_enable=YES
userlist_deny=YES
listen=YES
listen_ipv6=NO
max_per_ip=5
tcp_wrappers=YES
pam_service_name=vsftpd.vu
virtual_use_local_privs=YES
guest_enable=YES
guest_username=ftp
user_config_dir=$vfudir
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
chroot_local_user=YES
local_root=/var/ftp/
EOF
#chroot_list:open user
#chown -R ftp.ftp /var/ftp
#chmod -R a+t /vat/ftp/
touch /etc/vsftpd/chroot_list
mkdir -p $vfudir ; cd $vfudir
cat > $user <<EOF
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
local_root=/var/ftp/
EOF
/etc/init.d/vsftpd start
echo "Ending,Succeed!!!"
if [ "$SYS_VERSION" == "6" ] || [ "$SYS_VERSION" == "5" ]; then
  sed -i 's/IPTABLES_MODULES=""/IPTABLES_MODULES="nf_conntrack_ftp"/' /etc/sysconfig/iptables-config
  modprobe nf_conntrack_ftp
  iptables -I INPUT -p tcp --dport 21 -j ACCEPT
elif [ "$SYS_VERSION" == "7" ] ;then
  echo "Please check firewalld:stop or set rule."
fi
