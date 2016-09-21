#!/usr/bin/env python
# -*- coding:utf8 -*-

__author__ = "Mr.tao"
__date__   = "2016-06-02"
__doc__    = "baidu apistore test for http://apistore.baidu.com/apiworks/servicedetail/720.html"

import requests, json, shutil
import sys, os
reload(sys)
sys.setdefaultencoding("utf-8")
from sh import wget
from SendMailPics import SendMailPic

baseurl = "http://apis.baidu.com/txapi/mvtp/meinv"
apikey  = "e25c4d6a8a28349bb7a6cb076057c609"
num     = 10

r = requests.get(baseurl, headers={"apikey": apikey}, params={"num": num})
#print json.dumps(r.json(), indent=2, ensure_ascii=False)
#exit(1)

PicsDir="tmp_pic"
Imgs=[]
if not os.path.exists(PicsDir):os.mkdir(PicsDir)
os.chdir(PicsDir)
for New in r.json().get("newslist"):
    try:
        wget(New.get("picUrl"))
    except Exception:
        pass
for filename in os.listdir(r'.'):
    Imgs.append(filename)

value = SendMailPic(*Imgs)
if value != 0:
    print "send mail error"
else:
    os.chdir("..")
    shutil.rmtree(PicsDir)
