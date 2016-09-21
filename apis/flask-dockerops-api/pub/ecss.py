# -*- coding:utf8 -*-

import etcd
from tool import ip_check, logger


class ECSS:

    """Encapsulation Configuration Storage Service. The wrapper of ECSS for etcd API."""

    def __init__(self, etcd_host, etcd_port, etcd_scheme="http", read_timeout=5, allow_reconnect=True):
        if ip_check(etcd_host) == None:
            logger.error("IP(%s) format error in class ECSS"%etcd_host)
        self.ec = etcd.Client(host=etcd_host, port=etcd_port, protocol=etcd_scheme, read_timeout=read_timeout, allow_reconnect=allow_reconnect)
        logger.info("Start connect etcd, base_uri is %s, version_prefix is %s" %(self.ec.base_uri, self.ec.version_prefix))

    def get_all_keys(self, req="key"):
        """Get all valuable keys or keys length from etcd, return type is generator"""

        result = self.ec.read('/', recursive=True, sorted=True).children
        keys   = ((project.key, project.value) for project in result if project.value)

        if req == "key":
            logger.info("get_all_keys for key")
            return (project.key for project in result if project.value)

        elif req == "ip":
            logger.info("get_all_keys for ip")
            return (key[0].split("/")[-1] for key in keys)

        elif req == "length":
            logger.info("get_all_keys for length")
            return len(list(keys))

        else:
            return "req param is error, only `key` or `value`"

    def get(self, key, req="value"):
        res = self.ec.get(key).__dict__.get(req)
        logger.info("Get, key is %s, request is %s, res is %s" %(key, req, res))
        return res

    def set(self):
        pass

    def update(self):
        pass

    def delete(self):
        pass

    @property
    def base_uri(self):
        return self.ec.base_uri

    @property
    def version(self):
        return self.ec.version_prefix

    @property
    def leader(self):
        return self.ec.leader

    @property
    def stats(self):
        return self.ec.stats

    @property
    def store_stats(self):
        return self.ec.store_stats