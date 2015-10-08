#images

1    列出镜像
GET    /images/json  
参数
    all：1代表真，0代表假，默认是假    
    filters：一个json格式的键值对
 
curl -s -XGET 'http://0.0.0.0:4243/images/json?all=0'| python -m json.tool


2    创建一个镜像
POST    /images/create
参数
   fromImage：
   fromSrc：
   repo：仓库
   tag：tag标记
   registry：


3     给镜像中插入一个文件
POST    /images/(image name)/insert
#从url中取出文件插入到镜像的path里面
curl -s -XGET 'http://0.0.0.0:4243/images/insert?url=http://127.0.0.1/index.php&path=/opt'


4     检查一个镜像
GET    /images/(image name)/json
 
curl -s -XGET 'http://0.0.0.0:4243/images/ubuntu14/json'| python -m json.tool


5     获取镜像的历史
GET    /images/(image name)/history

curl -s -XGET 'http://0.0.0.0:4243/images/ubuntu14/history'| python -m json.tool


6     push镜像到仓库
POST    /images/(image name)/push
参数
   registry：哪个registry你想push


7    给仓库的镜像打tag
POST    /images/(image name)/tag
参数
   repo：The repository to tag in
   force：1代表真，0代表假，默认是假 

   
8    删除一个镜像
DELETE    /images/(image name)
参数
   force：1代表真，0代表假，默认是假  
   noprune：1代表真，0代表假，默认是假  
 
curl -s -XDELETE 'http://0.0.0.0:4243/images/ubuntu14'


9    搜索镜像
GET    /images/search
参数
    term：搜索哪个镜像
 
curl -s -XGET http://0.0.0.0:4243/images/search?term=nginx


10    利用Dockfile构建镜像
POST    /build
参数
   t：repository名称
   q：安静模式
   nocache：构建镜像时不使用cache
   rm：容器成功构建成功后删除中间层容器
   forcerm：删除中间层容器

   
11    检查认证
POST    /auth


12    显示系统信息
GET    /info
 
curl -s -XGET 'http://0.0.0.0:4243/info'| python -m json.tool


13    显示docker版本信息
GET    /version
curl -s -XGET 'http://0.0.0.0:4243/version'| python -m json.tool



14    ping docker server是否存活
GET    /_ping
curl -s -XGET 'http://0.0.0.0:4243/_ping'


15    利用现有的容器创建镜像，也就是commit
POST    /commit


16    监控docker事件
GET    /events
参数
    since：timestamp
    until：timestamp
	
