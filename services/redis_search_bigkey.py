# -*- coding: utf-8 -*-
"""
    redis_search_bigkey
    ~~~~~~~~~~~~~~

    说明：
        该命令支持查找 Redis 主从版本和集群版本的大 key ，默认大 key 的阈值为10240。string 类型的 value 大于10240的是大 key，list 长度大于10240认为是大 key，hash field 的数目大于10240认为是大 key。
        另外默认该脚本每次搜索1000个 key，对业务的影响比较低，不过最好在业务低峰期进行操作，避免 scan 命令对业务的影响。
    使用：
        pip install redis(针对单机、主从，集群版安装redis-cluter-py)
        python redis_search_bigkey.py host 6379 password
    链接：
        https://help.aliyun.com/knowledge_detail/56949.html
"""

import sys
import redis


def check_big_key(r, k, maxlen=10240):
    """根据阈值查找大key
    @param r instance: redis连接实例
    @param k str: key-键名
    @param maxlen int: 阈值，超过此值认为是大key，默认10240
    """
    bigKey = False
    length = 0
    try:
        t = r.type(k)
        if t == "string":
            length = r.strlen(k)
        elif t == "hash":
            length = r.hlen(k)
        elif t == "list":
            length = r.llen(k)
        elif t == "set":
            length = r.scard(k)
        elif t == "zset":
            length = r.zcard(k)
    except:
        return
    if length > maxlen:
        bigKey = True
    if bigKey:
        print "\t", t, length, k


def find_big_key_normal(host, port, auth, db, maxlen=10240):
    """单机、主从版"""
    r = redis.StrictRedis(host=host, port=port, password=auth, db=db)
    for k in r.scan_iter(count=1000):
        check_big_key(r, k, maxlen)


def find_big_key_sharding(host, port, auth, db, nodecount, maxlen=10240):
    """集群版-待测"""
    r = redis.StrictRedis(host=host, port=port, password=auth, db=db)
    cursor = 0
    for node in range(0, nodecount):
        while True:
            iscan = r.execute_command("iscan", str(node), str(cursor), "count", "1000")
            for k in iscan[1]:
                check_big_key(r, k, maxlen)
            cursor = iscan[0]
            print cursor, db, node, len(iscan[1])
            if cursor == "0":
                break


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", help="redis连接地址", default="localhost")
    parser.add_argument("--port", help="redis连接端口", default="6379")
    parser.add_argument("--auth", help="redis连接密码，默认为空", default="")
    parser.add_argument("--db", help="要查找的库，例如0，默认为所有", default="")
    parser.add_argument("--maxlen", help="定义大key的阈值", default="10240")
    args = parser.parse_args()
    host = args.host
    port = args.port
    auth = args.auth or None
    db = args.db
    maxlen = int(args.maxlen)
    if host and port:
        r = redis.StrictRedis(host=host, port=int(port), password=auth)
        if r.ping():
            nodecount = int(r.info().get("nodecount") or 0)
            keyspace_info = r.info("keyspace")
            if db:
                # db like 0, 1
                print 'check ', 'db{}'.format(db), ' ', keyspace_info.get("db{}".format(db))
                if nodecount > 1:
                    find_big_key_sharding(host, port, auth, db, nodecount, maxlen)
                else:
                    find_big_key_normal(host, port, auth, db, maxlen)
            else:
                for db in keyspace_info:
                    # db like db0, db1
                    print 'check ', db, ' ', keyspace_info[db]
                    if nodecount > 1:
                        find_big_key_sharding(host, port, auth, db.replace("db", ""), nodecount, maxlen)
                    else:
                        find_big_key_normal(host, port, auth, db.replace("db", ""), maxlen)
        else:
            print "无法连接Redis {}:{}".format(host, port)
    else:
        parser.print_help()
