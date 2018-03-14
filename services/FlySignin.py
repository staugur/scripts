# -*- coding: utf-8 -*-
"""
    FlySignin
    ~~~~~~~~~~~~~~

    Layui Fly 社区自动签到

    :copyright: (c) 2017 by taochengwei.
"""

__date__ = "2018-03-02"
__author__ = "taochengwei"
__version__ = "0.2"

import requests, logging, os.path, sys
from time import sleep
from random import choice

logging.basicConfig(
    level    = logging.INFO,
    format   = '[ %(levelname)s ] %(asctime)s %(filename)s:%(lineno)d %(message)s',
    datefmt  = '%Y-%m-%d %H:%M:%S',
    filename = os.path.join(os.path.dirname(os.path.abspath(__file__)), "%s.log" %sys.argv[0].split('.')[0]),
    filemode = 'a'
)

publicHeaders = {
    "Accept-Language": "zh-CN,zh;q=0.9",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36",
}

def sendWechatMsg(message):
    """ 发送微信消息 """
    if isinstance(message, basestring):
        apiUrl = ""
        header = dict(publicHeaders, AccessToken="")
        params = {"action": "weixin", "msgType": "text"}
        data   = {"msgContent": message}
        resp   = requests.post(apiUrl, params=params, headers=header, timeout=10, data=data).json()
        logging.info("Finished sendWechatMsg response: %s" %resp)
        return resp["success"]

def Signin(flyCookie, RANDOM_TIME_ENABLE=True):
    """自动签到
    @param flyCookie str: fly.layui.com登录后获取的`fly-layui`的cookie值
    @param RANDOM_TIME_ENABLE bool: 开启随机挂起几分钟后再签到的功能
    """
    if flyCookie:
        """ 登录签到步骤
        1. 查询状态
        url: http://fly.layui.com/sign/status
        method: post
        cookie: fly-layui=flyCookie
        data: 
        resp:
            未签到时 {"status":0,"data":{"days":0,"experience":5,"signed":false,"token":"8646fad920c0d3f6e7ff45ccbb5f0305e929811b"}}
            已签到后 {"status":0,"data":{"days":1,"experience":5,"signed":true}}

        2. 请求签到
        url: http://fly.layui.com/sign/in
        method: post
        cookie: fly-layui=flyCookie
        data: token=未签到时data中token或者1
        resp: 签到状态、天数、经验值等
        """
        if RANDOM_TIME_ENABLE is True:
            sleep(choice(range(6)) * 60)
        res = dict(msg=None)
        statusUrl = "http://fly.layui.com/sign/status"
        inUrl = "http://fly.layui.com/sign/in"
        cookies = {"fly-layui": flyCookie}
        try:
            status = requests.post(statusUrl, headers=publicHeaders, cookies=cookies).json()
        except Exception,e:
            logging.error(e, exc_info=True)
            res.update(msg="FlySignin failed when request status")
        else:
            logging.info("NO.1 status response: %s" %status)
            if status.get("status") == 0 and status.get("data", {}).get("signed") == False:
                try:
                    signin = requests.post(inUrl, headers=publicHeaders, cookies=cookies, data=dict(token=status["data"].get("token", 1))).json()
                except Exception,e:
                    logging.error(e, exc_info=True)
                    res.update(msg="FlySignin failed when request signin")
                else:
                    logging.info("NO.2 signin response: %s" %signin)
                    res.update(signin)
            else:
                res.update(status)
                res.update(msg="FlySignin getted invaild status data")
        logging.info(res)
        msg = u"[Layui签到成功]\n\t签到%s天、%s经验" %(res["data"]["days"], res["data"]["experience"]) if res.get("status") == 0 and res.get("data", {}).get("signed") == True else u"[Layui签到失败]"
        return sendWechatMsg(msg)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--flyCookie", help="fly.layui.com登录后获取的`fly-layui`的cookie值", default="")
    parser.add_argument("--RANDOM_TIME_ENABLE", help="随机暂停几分钟功能是否启用", default=False, action='store_true')
    args = parser.parse_args()
    flyCookie = args.flyCookie
    RANDOM_TIME_ENABLE = args.RANDOM_TIME_ENABLE
    if flyCookie:
        try:
            Signin(flyCookie, RANDOM_TIME_ENABLE)
        except Exception,e:
            logging.error(e, exc_info=True)
    else:
        parser.print_help()
