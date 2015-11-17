#!/bin/bash
#SaintIC Sdp svn.
source /etc/profile
yum -y install httpd subversion mod_ssl mod_dav_svn
sed -i "s/#ServerName www.example.com:80/ServerName ${HOSTNAME}/g" /etc/httpd/conf/httpd.conf
svnconf=/etc/httpd/conf.d/subversion.conf
httpasswd=/etc/httpd/conf.d/.httpasswd
mv $svnconf ${svnconf}.bak
cat > $svnconf<<EOF
LoadModule dav_svn_module     modules/mod_dav_svn.so
LoadModule authz_svn_module   modules/mod_authz_svn.so
<Directory "/data/">
	Order allow,deny
	Allow from all
</Directory>
<Location /sdi/test>
   DAV svn
   SVNPath /data/repos/test
   AuthType Basic
   AuthName "SDI Code Service"
   AuthUserFile /data/repos/.passwd
   #SSLRequireSSL
  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
EOF
mkdir -p /data/repos/ && svnadmin create /data/repos/test
htpasswd -bc /data/repos/.passwd test test
echo "Ending,Succeed!!!"
echo "Please install SSL certs and enable SSLRequireSSL in 26 line."


function create_svn() 
{
[ "$#" != "3" ] && ERROR
#arg:$init_user $init_passwd $init_user_home_root
cat >> $svnconf <<EOF

<Location /sdi/$1>
   DAV svn
   SVNPath $3
   AuthType Basic
   AuthName "Welcome to SDI CodeSourceRoot."
   AuthUserFile $httpasswd
   #SSLRequireSSL
  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
EOF
chown -R apache:apache $3
[ -e $httpasswd ] && htpasswd -mb $httpasswd $1 $2 || htpasswd -bc $httpasswd $1 $2
/etc/init.d/httpd reload
}

