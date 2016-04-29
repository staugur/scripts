#coding:utf8
"""
获取源代码
git clone https://github.com/dvarrazzo/py-setproctitle.git

编译
python setup.py build
python setup.py install
"""


import setproctitle
setproctitle.setproctitle("进程别名")
