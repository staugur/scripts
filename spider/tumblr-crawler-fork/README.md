tumblr-crawler
===============

这是一个[Python](https://www.python.org)的脚本,配置运行后可以从某些你指定的tumblr博客
下载图片和视频.
源代码库为https://github.com/dixudx/tumblr-crawler， 本代码为玄魂拷贝过来，做了部分修改。
## 环境安装
### 首先要安装python环境，安装最新版即可
#### 下载代码，安装依赖
```bash
$ git clone https://github.com/xuanhun/tumblr-crawler.git
$ cd tumblr-crawler
$ pip install -r requirements.txt
```

大功告成,直接跳到下一节配置和运行.




## 配置和运行

有两种方式来指定你要下载的站点,一是编辑`sites.txt`,二是指定命令行参数.

### 第一种方法:编辑sites.txt文件（推荐）
找到一个文字编辑器,然后打开文件`sites.txt`,把你想要下载的Tumblr站点编辑进去,以逗号分隔,不要有空格,不需要`.tumblr.com`的后缀.例如,如果你要下载 _vogue.tumblr.com_ and _gucci.tumblr.com_,这个文件看起来是这样的:

```
vogue,gucci
```

然后保存文件,双击运行`tumblr-photo-video-ripper.py`或者在终端(terminal)里面
运行`python tumblr-photo-video-ripper.py`

### 第二种方法:使用命令行参数(仅针对会使用操作系统终端的用户)

如果你对Windows或者Unix系统的命令行很熟悉,你可以通过指定运行时的命令行参数来指定要下载的站点:

```bash
python tumblr-photo-video-ripper.py site1,site2
```

站点的名字以逗号分隔,不要有空格,不需要`.tumblr.com`的后缀.

### 站点图片/视频的下载与保存

程序运行后,会默认在当前路径下面生成一个跟tumblr博客名字相同的文件夹,
照片和视频都会放在这个文件夹下面.

运行这个脚本,不会重复下载已经下载过的图片和视频,所以不用担心重复下载的问题.同时,多次运行可以
帮你找回丢失的或者删除的图片和视频.

### 使用代理 (可选)
你如果不能直接访问Tumblr或者没有使用VPN，就需要配置代理。

文件格式参考`./proxies_sample1.json`和`./proxies_sample2.json`.
然后把你的代理信息用json的格式写入`./proxies.json`.
你可以访问<http://jsonlint.com/>以确保你的格式是正确的.

如果文件`./proxies.json`没有任何内容,下载过程中不会使用代理.

如果你是全局模式使用Shadowsocks做代理, 此时你的`./proxies.json`文件可以写入如下内容,

```json
{
    "http": "socks5://127.0.0.1:1080",
    "https": "socks5://127.0.0.1:1080"
}
```

然后重新运行下载命令.

