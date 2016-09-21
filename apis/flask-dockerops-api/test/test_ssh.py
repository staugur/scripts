# coding:utf8

import sys
sys.path.append("..")
from pub.ssh import ssh2, ssh2_async_coroutine
from pub.ecss import ECSS
import unittest
import gevent
import time
from threading import Thread

class SSHTest(unittest.TestCase):


    def test_connect(self):
        _st = time.time()
        cmd = """for cid in $(docker ps | grep -v CONTAINER | awk '{print $1}'); do docker inspect -f "State:{{json .State.Running}}, StartedAt:{{json .State.StartedAt}}, Volumes:{{json .HostConfig.Binds}}, ImageId:{{json .Image }}, ImageName:{{json .Config.Image }}" $cid ; done"""
        ips = ECSS("221.122.127.163", 10020).get_all_keys()
        for key in ips:
            ip = key[0].split("/")[-1]
            print "test_connect %s" %ip
            r= ssh2(ip=ip, cmd=cmd)
            gevent.sleep(0)
        print r
        _et = time.time()
        print "Runtime is ", _et - _st, "s"

    def test_a_ip(self):
        ips = ("123.59.17.237", "123.59.17.238", "123.59.17.239")
        #ips = "123.59.17.237"
        ips = ("106.38.251.8",)
        #cmd = """for cid in $(docker ps | grep -v CONTAINER | awk '{print $1}'); do docker inspect -f "State:{{json .State.Running }}, StartedAt:{{json .State.StartedAt }}, Volumes:{{json .HostConfig.Binds }}, ImageId:{{json .Image }}, ImageName:{{json .Config.Image }}" $cid ; done"""
        cmd = """for cid in $(docker ps | grep -v CONTAINER | awk '{print $1}'); do docker inspect -f {'"State": {{json .State.Running }}, "StartedAt": {{json .State.StartedAt }}, "Volumes": {{json .HostConfig.Binds }}, "ImageId": {{json .Image }}, "ImageName": {{json .Config.Image }}'} $cid ; done"""
        r = ssh2_async_coroutine(cmd=cmd, ips=ips)
        import json
        for _r in r:
            if isinstance(_r, (list, tuple)):
                for i in _r:
                    try:
                        print json.loads(i)
                    except Exception, e:
                        raise
            else:
                print type(_r), len(_r)

if __name__ == '__main__':
    unittest.main()
