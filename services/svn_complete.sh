#!/bin/bash
#多功能多用户svn版本库服务器
SYS_NAME=$(python -c "import platform;print platform.linux_distribution()[0]")
SYS_VERS=$(python -c "import platform;print platform.linux_distribution()[1]")
if [ -z $SYS_NAME ] || [ -z $SYS_VERS ];then
  echo "Please install python,eg:yum -y install python";
  exit 1
fi

function SVN_ONLY() {
if [ $SYS_NAME == "CentOS" ] || [ $SYS_NAME == "RHEL" ] ||[ $SYS_NAME == "Fedora" ];then
yum -y install subversion
cat > /etc/init.d/svnserve <<"EOF"
#!/bin/bash
#chkconfig:2345 17 40
#description:Subversion
svnport=$(netstat -natp | grep svnserve | awk '{print $4}' | awk -F: '{print $2}')
svnhome="/data/repos"
conf="${svnhome}/svnserve.conf"
args="--daemon --pid-file=/var/run/svnserve.pid -r $svnhome --config-file $conf"
exec=$(which svnserve)
case "$1" in
start)
  if [ "$svnport" = "3690" ];then
    echo "SVN Server Already Runnning. Pid:$(netstat -anptl|grep svn|awk -F "LISTEN" '{print $2}'|awk -F "/" '{print $1}'|awk '{print $1}')"
  else
    $exec $args
    if [ $(ps aux|grep -v grep|grep svn|wc -l) -ge 1 ];then
      echo -n "Start Subversion, pid($(cat /var/run/svnserve.pid))......";
      echo -e "\033[31mSuccess\033[0m"
    fi
  fi
  ;;
stop)
  pkill svnserve &> /dev/null
  if [ $? -eq 0 ];then
    echo "SVN Server 已经停止！"
  else
    kill -9 $(cat /var/run/svnserve.pid);echo "强制杀死SVN进程。"
  fi
  ;;
status)
  pid=$(ps aux | grep svnserve | grep -v "grep" | awk '{print $2}') &> /dev/null
  if [ "$svnport" = "3690" ] || [ $svnpid != "0" ];then
    echo -n "PID: ${pid}; 监听地址及端口如下: "; netstat -anptl | grep svnserve
  else
    echo "SVN Server 停止运行..."
  fi
  ;;
restart)
  $0 stop
  $0 start
  ;;
*)
  echo "$0: Usage: $0 {start|status|stop|restart}"
  exit 1
  ;;
esac
EOF
[ -d /data/repos ] || mkdir -p /data/repos
cat > /data/repos/authz<<EOF
[aliases]
[groups]
EOF
cat > /data/repos/passwd<<EOF
[users]
EOF
cat > /data/repos/svnserve.conf<<EOF
[general]
anon-access = read
auth-access = write
password-db = passwd
authz-db = authz
realm = SIC Repository
[sasl]
EOF
chmod +x /etc/init.d/svnserve;chkconfig --add svnserve;chkconfig svnserve on
service svnserve start
#add user:
  #>>/data/repos/passwd,format=user:passwd
#add repo:
  #>>/data/repos/authz,format={
    #[repo_name:/]
    #@group=rw
    #user=rw
    #*=r}
else
  printf "不支持的系统:$SYS_NAME\n"
fi
}


function public() {
sed -i "s/#ServerName www.example.com:80/ServerName ${HOSTNAME}/g" /etc/httpd/conf/httpd.conf
[ -d /data/repos/saintic ] || mkdir -p /data/repos/saintic && svnadmin create /data/repos/test
htpasswd -bc /data/repos/.passwd test test
/etc/init.d/httpd start
if [ `netstat -anptl|grep httpd|wc -l` -ge 1 ];then
  echo "Ending,Succeed!!!"
else
  echo "Start Fail"
fi
}

function HTTP_ONLY() {
yum -y install httpd subversion mod_dav_svn
svnconf="/etc/httpd/conf.d/subversion.conf"
mv $svnconf ${svnconf}.bak
cat > $svnconf<<EOF
LoadModule dav_svn_module     modules/mod_dav_svn.so
LoadModule authz_svn_module   modules/mod_authz_svn.so
<Directory "/data/">
  Order allow,deny
  Allow from all
</Directory>
#only version library
<Location /staugur/test>
   DAV svn
   SVNPath /data/repos/test
   AuthType Basic
   AuthName "My Code Service"
   AuthUserFile /data/repos/.passwd
  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
#father version library
<Location /saintic>
   DAV svn
   SVNParentPath /data/repos/saintic/
   SVNListParentPath on
   AuthType Basic
   AuthName "Group: saintic."
   AuthUserFile /data/repos/.passwd
  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
EOF
public
}


function HTTPS_ONLY() {
yum -y install httpd subversion mod_ssl mod_dav_svn openssl openssl-devel
sed -i "s/Listen 80/#Listen 80/g" /etc/httpd/conf/httpd.conf
openssl req -new -x509 -days 3650 -keyout server.key -out server.crt -subj '/CN=Test-only certificate' -nodes
mv -f server.key /etc/pki/tls/private/localhost.key
mv -f server.crt /etc/pki/tls/certs/localhost.crt
svnconf="/etc/httpd/conf.d/subversion.conf"
mv $svnconf ${svnconf}.bak
cat > $svnconf<<EOF
LoadModule dav_svn_module     modules/mod_dav_svn.so
LoadModule authz_svn_module   modules/mod_authz_svn.so
<Directory "/data/">
  Order allow,deny
  Allow from all
</Directory>
#only version library
<Location /staugur/test>
   DAV svn
   SVNPath /data/repos/test
   AuthType Basic
   AuthName "My Code Service"
   AuthUserFile /data/repos/.passwd
   SSLRequireSSL
  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
#father version library
<Location /saintic>
   DAV svn
   SVNParentPath /data/repos/saintic/
   SVNListParentPath on
   AuthType Basic
   AuthName "Group: saintic."
   AuthUserFile /data/repos/.passwd
   SSLRequireSSL
  <LimitExcept GET PROPFIND OPTIONS REPORT>
    Require valid-user
  </LimitExcept>
</Location>
EOF
public
}

case $1 in
SVN|svn)
  SVN_ONLY
  ;;
HTTP|http|httpd)
  HTTP_ONLY
  ;;
HTTPS|https)
  HTTPS_ONLY
  ;;
*)
  echo -e "\033[31m$0 require: SVN HTTP HTTPS\033[0m"
  exit 3
  ;;
esac
 
