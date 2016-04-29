#!/usr/bin/env python
#coding:utf8
__author__ = 'saintic.com'
__version__ = '1.0'
__doc__ = '固定容器IP：获取id对应的ip写入redis，下次启动读取配置'

import redis,sys,subprocess
db = redis.Redis(host='127.0.0.1',port=6379,db=1,password=None)

def set_kv(id,ip):
  if db.exists(id) ==  True:
    print "ID Exists\n"
    sys.exit(1)
  else:
    db.set(id,ip)
    db.save()

def start():
  try:
    if len(sys.argv) == 3:
      id=sys.argv[1]
      ip=sys.argv[2]
      subprocess.call(['sh ' + 'run.sh ' + id + ' ' +  ip],shell=True)
      set_kv(id,ip)
  except:
    print 'Start Error'

def start_agent():
  id=sys.argv[1]
  ip=db.get(id)
  subprocess.call(['sh ' + 'run.sh ' + id + ' ' +  ip],shell=True)

start_agent()

