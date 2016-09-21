#!/usr/bin/python
# coding:utf8

__author__  = 'Mr.tao'
__url__ = 'www.saintic.com'

import time
import urllib2
from multiprocessing.dummy import Pool as ThreadPool

workers = 12
urls = [
    "https://api.saintic.com/",
    "https://api.saintic.com/blog",
    "http://api.saintic.com:10040/blog?get_catalog_list=true&get_sources_list=true",
    "http://api.saintic.com:10040/blog?get_catalog_data=true",
    "http://api.saintic.com:10040/blog?get_sources_data=true",
    "http://api.saintic.com:10040/blog?limit=20",
]

def ConcurrentTest(urls):
    try:
        start = time.time()
        map(urllib2.urlopen, urls)
        print 'Normal:', time.time() - start
        start2 = time.time()
        pool = ThreadPool(processes=workers)
        pool.map(urllib2.urlopen, urls)
        #pool.close()
        #pool.join()
    except Exception,e:
        print e

def ConcurrentTestRegistry(R):
    try:
        import requests
        urls = ("https://api.saintic.com/user?action=reg", "http://127.0.0.1:10040/user?action=reg", "http://101.200.125.9:10041/user?action=reg")
        data = {"username": "test_" + str(R), "password": "910323"}
        print data
        post = lambda url:requests.post(url, data=data, verify=False, timeout=3).json()
        pool = ThreadPool(processes=workers)
        print pool.map(post, urls)
    except Exception,e:
        print e

if __name__ == "__main__":
    import random
    while 1 > 0:
        ConcurrentTest(urls)
        #time.sleep(1)
	#ConcurrentTestRegistry(random.randint(1, 9999))
        time.sleep(1)
