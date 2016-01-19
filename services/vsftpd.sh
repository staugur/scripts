#!/bin/bash
#Create virtual ftp users, first user is test
error() {
  exit 1
  echo "Error,args is 2"
}
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
/etc/init.d/vsftpd restart
echo "Ending,Succeed!!!"
echo "Please check iptables or firewalld, SELinux."



#/bin/bash
#create virtual ftp user.
[ "$#" != "3" ] && ERROR
#arg:$init_user $init_passwd $init_user_home_root
vfu=/etc/vsftpd/vfu.list
vfudb=/etc/vsftpd/vfu.db
vfudir=/etc/vsftpd/vfu_dir
cat >> $vfu <<EOF
$1
$2
EOF
db_load -T -t hash -f $vfu $vfudb
cat > ${vfudir}/$1 <<EOF
write_enable=YES
anon_world_readable_only=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
local_root=$3
EOF
chown -R ftp.ftp $3
chmod -R a+t $3
/etc/init.d/vsftpd reload