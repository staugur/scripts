#!/usr/bin/env python
#coding:utf8
__author__ = 'saintic.com'
__version__ = '2.0'
__date__ = '2015-09-16'
__doc__ = '固定容器ip：获取id对应的ip写入redis，下次启动读取配置'

import redis,sys
db = redis.Redis(host='127.0.0.1',port=6379,db=1,password=None)

def set_kv(cid,cip):
  if cid == None or cip == None:
    sys.exit(1)
  if db.exists(cid) ==  True:
    print "cid Exists\n"
    sys.exit(3)
  else:  #cid = False
    if db.get(cid) == cip:
      print "cip Exists\n"
      sys.exit(1)
    else:
      db.set(cid,cip)
      db.save()
      return (cid,cip)

def get_kv(cid):
  if cid == None:
    sys.exit(1)
  cip=db.get(cid)
  return cip

if len(sys.argv) == 4:
  cid=sys.argv[2]
  cip=sys.argv[3]
  if sys.argv[1] == start:
    set_kv(cid,cip)
  elif sys.argv[1] == restart:
    get_kv(cid)
