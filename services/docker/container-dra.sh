#Docker remote API

1.列出容器
GET    /containers/json
参数
    all：1表示真，0表示假，显示所有的容器，默认显示只在运行的容器
    limit：显示最后创建的哪些容器，包括未运行的容器
    since：显示容器的ID，包括未运行的容器
    before：显示在哪个容器的ID创建之前的容器，包括未运行的容器
    size：1表示真，0表示假，显示容器的大小
 
curl -s -XGET 'http://0.0.0.0:4243/containers/json?all=1'| python -m json.tool
curl -s -XGET http://182.92.106.104:4243/containers/json | python -m json.tool


2.列出容器
GET    /containers/(container id)/json
curl -s -XGET 'http://0.0.0.0:4243/containers/7101b7cbb261/json'| python -m json.tool


3.创建容器?????
POST   /containers/create
参数
   config：容器的配置文件
   或者使用json格式的POST数据
 
curl -s -XGET 'http://0.0.0.0:4243/containers/create'  HTTP/1.1 Content-Type: application/json {  }


4.列出正在运行的容器里面的进程
GET    /containers/(container id)/top
参数
    ps_args：传递给ps的参数，例如使用aux参数
 
curl -s -XGET 'http://0.0.0.0:4243/containers/7101b7cbb261/top'| python -m json.tool



5.获取一个容器的logs??????
GET /containers/(container id)/logs
参数
    follow：1代表真，0代表假，返回stream流日志，默认是假
    stdout：1代表真，0代表假，如果logs=true，则返回stdout log，默认是假
    stderr：1代表真，0代表假，如果logs=true，则返回stderr log，默认是假
    timestamps：1代表真，0代表假，如果logs=true，则在每一行日志前打印一个timestamps，默认是假
 
curl -s -XGET 'http://0.0.0.0:4243/containers/7101b7cbb261/logs?stdout=1&follow=1&timestamps=1'



6.检查一个容器的改变
GET    /containers/(container id)/changes
 
curl -s -XGET 'http://0.0.0.0:4243/containers/7101b7cbb261/changes'|python -m json.tool


7.导出容器内容
GET    /containers/(container id)/export
#导出一个容器，千万不要随便尝试
curl -s -XGET 'http://0.0.0.0:4243/containers/7101b7cbb261/export'


8.启动一个容器
POST /containers/(container id)/start
curl -s -XPOST 'http://0.0.0.0:4243/containers/a9c07396bd0b/start'


9.停止一个容器
POST    /containers/(container id)/stop
参数
   t：等待多少秒之后再停止容器

curl -s -XPOST 'http://0.0.0.0:4243/containers/a9c07396bd0b/stop'


10.重启一个容器
POST    /containers/(container id)/restart
参数
   t：等待多少秒之后再重启容器
 
curl -s -XPOST 'http://0.0.0.0:4243/containers/a9c07396bd0b/restart'


11    杀死一个容器
POST    /containers/(container id)/kill
参数
    signal：发送一个什么信号给容器，可以是数字也可以是“SIGINT”
curl -s -XPOST 'http://0.0.0.0:4243/containers/eed3c6ff4821/kill'


12.附加到一个容器上
POST    /containers/(container id)/attach
参数
    logs：1代表真，0代表假，返回logs，默认是假
    stream：代表真，0代表假，返回stream，默认是假
    stdout：1代表真，0代表假，如果logs=true，则返回stdout log，如果stream=true，则attach到stdout上，默认是假
    stderr：1代表真，0代表假，如果logs=true，则返回stderr log，如果stream=true，则attach到stderr上，默认是假
    stdin：1代表真，0代表假，如果stream=true，则attach到stdin上，默认是假
 
curl -s -XPOST 'http://0.0.0.0:4243/containers/7101b7cbb261/attach?logs=1&stream=1&stdout=1'


13.阻止一个容器直到该容器退出
POST    /containers/(container id)/wait

curl -s -XPOST 'http://0.0.0.0:4243/containers/7101b7cbb261/wait'


14.删除一个容器
DELETE    /containers/(container id)
参数
   v：1代表真，0代表假，删除volumes和容器的联系，默认是假
   force：1代表真，0代表假，即使容器在运行，也删除容器

curl -s -XDELETE 'http://0.0.0.0:4243/containers/3457e4cd8398'


15    从容器里面拷贝文件或者目录
POST    /containers/(container id)/copy


