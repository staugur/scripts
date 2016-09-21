# coding:utf8

import sys
sys.path.append("..")
from pub.ssh import ssh2, ssh2_async_coroutine
from pub.ecss import ECSS
from pub.engine import DOCKER_CMD
import unittest
import json
import gevent

class SSHTest(unittest.TestCase):

    def setUp(self):
        self.ip = "106.38.251.8"
        self.docker = DOCKER_CMD(self.ip)

    def test_container_default(self):
        assert type(self.docker.Containers()) == dict

    def test_container_all(self):
        assert type(self.docker.Containers(All=True)) == dict

    def test_container_inspect(self):
        data = self.docker.Containers(All=True)
        #print data
        #gevent.sleep(0)
        assert type(data) == list
        for d in data:
            d = json.loads(d)
            assert "State" in d
            assert "StartedAt" in d
            assert "ImageName" in d

if __name__ == '__main__':
    unittest.main()
