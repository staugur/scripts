# coding: utf8
# author: taochengwei <taochengwei@emar.com>
# date:   2016-09-27

import logging
from time import sleep
from kazoo.client import KazooClient

logging.basicConfig(level=logging.DEBUG,
                format='%(asctime)s %(filename)s:%(lineno)d %(levelname)s %(message)s',
                filename='monitor.log',
                filemode='a')

zk = KazooClient(hosts="192.168.5.207:2181,192.168.5.206:2181,192.168.5.209:2181")
zk.start()

if __name__ == "__main__":
    path = "/sys/test/ids/192.168.6.103:10030"
    while 1:
        if not zk.connected:
            logging.warn("not zk connected, will start")
            zk.start()
        if not zk.exists(path):
            logging.info("not zk path, will create")
            zk.create(path)
        logging.info("exists zk path, pass")
        sleep(2)
