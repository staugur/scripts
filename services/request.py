#!/usr/bin/python2.7
# -*- coding: utf-8 -*-
#
# Python Client for Signature
#

import requests, hashlib, datetime, time, json, re

md5 = lambda pwd: hashlib.md5(pwd).hexdigest()
comma_pat = re.compile(r'\s*,\s*')
emicolon_pat = re.compile(r'\s*;\s*')
get_current_timestamp = lambda: int(time.mktime(datetime.datetime.now().timetuple()))

class RequestClient(object):
    """ 接口签名客户端示例 """

    def __init__(self, version, accesskey_id, accesskey_secret, debug=False):
        self._version = version
        self._accesskey_id = accesskey_id
        self._accesskey_secret = accesskey_secret
        self.debug = debug

    def _sign(self, parameters):
        """ 签名
        @param parameters dict: uri请求参数(包含除signature外的公共参数)
        """
        if "signature" in parameters:
            parameters.pop("signature")
        # NO.1 参数排序
        _my_sorted = sorted(parameters.items(), key=lambda parameters: parameters[0])
        # NO.2 排序后拼接字符串
        canonicalizedQueryString = ''
        for (k, v) in _my_sorted:
            canonicalizedQueryString += '{}={}&'.format(k,v)
        canonicalizedQueryString += self._accesskey_secret
        # NO.3 加密返回签名: signature
        return md5(canonicalizedQueryString).upper()

    def make_url(self, params={}):
        """生成请求参数
        @param params dict: uri请求参数(不包含公共参数)
        """
        if not isinstance(params, dict):
            raise TypeError("params is not a dict")
        # 获取当前时间戳
        timestamp = get_current_timestamp() - 4
        # 设置公共参数
        publicParams = dict(accesskey_id=self._accesskey_id, version=self._version, timestamp=timestamp)
        # 添加加公共参数
        for k,v in publicParams.iteritems():
            params[k] = v
        uri = ''
        for k,v in params.iteritems():
            uri += '{}={}&'.format(k,v)
        uri += 'signature=' + self._sign(params)
        return uri

    def request(self, url, params={}, post={}, cookies={}, method="GET", nojson=False):
        """发起请求"""
        if "://" in url and isinstance(params, dict) and method in ("GET","POST","DELETE","PUT"):
            url = '{}?{}'.format(url, self.make_url(params))
            if self.debug: print url
            if method == "GET":
                data = requests.get(url, cookies=cookies).json()
            if method == "POST":
                data = requests.post(url, cookies=cookies, data=post).json()
            if method == "DELETE":
                data = requests.delete(url, cookies=cookies, data=post).json()
            if method == "PUT":
                data = requests.put(url, cookies=cookies, data=post).json()
        else:
            data = dict(msg="ERROR")
        if nojson:
            return data
        else:
            return json.dumps(data)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", help="Interface address, which does not contain query parameters")
    parser.add_argument("-q", "--query", help="Interface query parameters, format: 'key1=value, key2=value,...'")
    parser.add_argument("-d", "--data", help="Interface data parameters, format: 'key1=value, key2=value,...'")
    parser.add_argument("--cookie", help="Request Cookie, format: 'key1=value; key2=value,...'")
    parser.add_argument("--method", help="Request Method. Default: GET", default="GET")
    parser.add_argument("--signVersion", help="Signature version. Default: v1", default="v1")
    parser.add_argument("--signId", help="Signature AccesskeyId. Default: accesskey_id", default="accesskey_id")
    parser.add_argument("--signSecret", help="Signature AccesskeySecret. Default: accesskey_secret", default="accesskey_secret")
    parser.add_argument("--debug", help="Debug mode. Default: false", default=False, action='store_true')
    parser.add_argument("--nojson", help="Show result without json format. Default: false", default=False, action='store_true')
    args = parser.parse_args()
    url = args.url
    query = args.query
    postdata = args.data
    cookie = args.cookie
    method = args.method.upper()
    signVersion = args.signVersion
    signId = args.signId
    signSecret = args.signSecret
    debug = args.debug
    nojson = args.nojson
    if url and signVersion and signId and signSecret and method:
        query = dict([i.split('=') for i in re.split(comma_pat, query.strip()) if i]) if query else {}
        postdata = dict([i.split('=') for i in re.split(comma_pat, postdata.strip()) if i]) if postdata else {}
        cookie = dict([i.split('=') for i in re.split(emicolon_pat, cookie.strip()) if i]) if cookie else {}
        signClient = RequestClient(version=signVersion, accesskey_id=signId, accesskey_secret=signSecret, debug=debug)
        print signClient.request(url=url, params=query, post=postdata, cookies=cookie, method=method, nojson=nojson)
    else:
        parser.print_help()

