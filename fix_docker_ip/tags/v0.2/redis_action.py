#!/usr/bin/env python
#coding:utf8
__author__ = 'saintic.com'
__version__ = '1.0'
__date__ = '2015-08-15'
__doc__ = '固定容器IP：获取id对应的ip写入redis，下次启动读取配置'

import redis,sys
db = redis.Redis(host='127.0.0.1',port=6379,db=1,password=None)

def set_kv(id,ip):
  if db.exists(id) ==  True:
    print "ID Exists\n"
    sys.exit(3)
  else:  #ID = False
    if db.get(id) == ip:
      print "IP Exists\n"
      sys.exit(1)
    else:
      db.set(id,ip)
      db.save()

def get_kv(id)
  ip=db.get(id)
  print ip

if len(sys.argv) == 4:
  id=sys.argv[2]
  ip=sys.argv[3]
  if sys.argv[1] == start:
    set_kv(id,ip)
  elif sys.argv[1] == restart:
    get_kv(id)
