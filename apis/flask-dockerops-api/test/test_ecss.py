# coding:utf8

import sys
import time
import unittest
sys.path.append("..")
from pub.ecss import ECSS
from pub.tool import ip_check

class ECSSTest(unittest.TestCase):

    def setUp(self):
        self.ec = ECSS("221.122.127.163", 10020)

    def test_ecss_key(self):
        keys = self.ec.get_all_keys(req="key")
        for key in keys:
            assert None != ip_check(key.split("/")[-1])

    def test_ecss_ip(self):
        ips = self.ec.get_all_keys(req="ip")
        for ip in ips:
            assert None != ip_check(ip)

    def test_ecss_length(self):
        length = self.ec.get_all_keys(req="length")
        assert type(length) is int

    def test_ecss_req_error(self):
        assert "param is error" in self.ec.get_all_keys(req='other')

    def test_ecss_get_value(self):
        key = self.ec.get_all_keys(req="key").next()
        assert "192.168." in self.ec.get(key)

if __name__ == '__main__':
    unittest.main()
