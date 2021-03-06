# -*- coding: utf-8 -*-
"""
    migrateredis.py
    ---------------

    迁移redis数据，可以从本机迁移到其他机器，迁移一个库或多个库中数据。

    原理：redis dump/restore命令

    依赖：pip install redis>=2.10.5
"""

from sys import argv
from redis import from_url, RedisError

def migrate(src_url, dst_url):
    src = from_url(src_url)
    dst = from_url(dst_url)
    for key in src.keys():
        try:
            dst.restore(key, src.ttl(key) or 0, src.dump(key))
        except RedisError as e:
            print(e)
            print('Migrate %s failed' % key)

if __name__ == "__main__":
    # 源redis的url，格式：
    #redis://[:password]@host:port/db
    #host,port必填项,如有密码,记得密码前加冒号,比如redis://localhost:6379/0
    src_url = argv[1]
    # 迁移目标redis的url
    dst_url = argv[2]
    # 执行
    if src_url and dst_url:
        migrate(src_url, dst_url)
