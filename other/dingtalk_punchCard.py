# -*- coding: utf-8 -*-
"""
    dingtalk_punchCard
    ~~~~~~~~~~~~~~~~~~

    自动调起钉钉考勤打卡

    :copyright: (c) 2018 by taochengwei.
    :license: MIT, see LICENSE for more details.
"""

import os
import json
import time
import urllib
import urllib2
import traceback
from tempfile import gettempdir


def post(url, data, token=None):
    """ POST请求 """
    if isinstance(data, dict):
        data = urllib.urlencode(data)  # 将字典以url形式编码
    headers = {'AccessToken': token} if token else {}
    headers.update({"User-Agent": "Mozilla/5.0 (X11; CentOS; Linux i686; rv:7.0.1406) Gecko/20100101 OpsRequestBot/0.1"})
    request = urllib2.Request(url, data=data, headers=headers)
    response = urllib2.urlopen(request)
    response = response.read()
    try:
        data = json.loads(response)
    except Exception, e:
        traceback.print_exc()
        data = response
    return data


class PunchCard(object):

    def __init__(self, adb="adb", coordinates=None):
        #: adb命令
        self.adb = adb
        #: 坐标，二维list、tuple，3个元素，每个元素是一个tuple，即((x, y), (x, y), (x,y))，分别是：进入钉钉-工作区域的坐标、钉钉-进入考勤打卡坐标、钉钉-点击考勤打卡坐标
        #: 开启开发者选项中指针位置，手动打开钉钉-工作-考勤打卡等按钮获取坐标
        assert isinstance(coordinates, (list, tuple))
        assert len(coordinates) == 3
        assert isinstance(coordinates[0], (list, tuple)) and len(coordinates[0]) == 2 and type(coordinates[0][0]) is int and type(coordinates[0][-1]) is int
        assert isinstance(coordinates[1], (list, tuple)) and len(coordinates[1]) == 2 and type(coordinates[1][0]) is int and type(coordinates[1][-1]) is int
        assert isinstance(coordinates[2], (list, tuple)) and len(coordinates[2]) == 2 and type(coordinates[2][0]) is int and type(coordinates[2][-1]) is int
        self.coordinates = coordinates

    def _call_cmd(self, cmd):
        """python2.7在windows下执行命令并获取返回值和输出"""
        status = -1
        output = None
        filename = os.path.join(gettempdir(), 'dingtalk.tmp')
        try:
            status = os.system("%s > %s" % (cmd, filename))
        except Exception, e:
            output = str(e)
        else:
            with open(filename, "r") as fp:
                output = fp.read().strip()
        finally:
            return status, output

    def _exec_cmd(self, cmd):
        """python2.7在windows下执行命令并获取返回值"""
        try:
            status = os.system(cmd)
        except Exception, e:
            return str(e)
        else:
            return status

    def _next_cmd(self, cmd, status, sec=3):
        """当status=0时执行cmd"""
        if status == 0:
            #: 执行命令前，如果sec>0，则等待加载sec秒"""
            if sec > 0:
                time.sleep(sec)
            return self._exec_cmd(cmd)
        return status

    def AutoIn(self):
        """自动考勤打卡-无论上下班。
        要求：
            python2.7
            adb(windows版本adb下载地址: https://adb.clockworkmod.com/)
            仅连接一台安卓手机，且手机开启开发者选项、允许USB调试、允许模拟点击(即USB调试(安全设置))、没有锁屏(即按电源键可唤醒屏幕，允许直接进入系统)
        使用：
            修改底部配置处的`coordinates`坐标，自行开启指针查看几个按钮的x、y坐标
        """
        #: 查看设备
        status, output = self._call_cmd("%s devices" % self.adb)
        if "device" not in output:
            #: 第一次连接设备可能是unauthorized，需要手机授权连接请求
            return status, output
        #: 点击电源键唤醒屏幕
        status = self._next_cmd("%s shell input keyevent 26" % self.adb, status, 0)
        #: 返回桌面
        status = self._next_cmd("%s shell input keyevent 3" % self.adb, status, 1)
        #: 启动钉钉应用
        status = self._next_cmd("%s shell monkey -p com.alibaba.android.rimet -c android.intent.category.LAUNCHER 1" % self.adb, status, 5)
        #: 进入钉钉-工作区域
        status = self._next_cmd("%s shell input tap %d %d" % (self.adb, self.coordinates[0][0], self.coordinates[0][-1]), status)
        #: 进入考勤打卡
        status = self._next_cmd("%s shell input tap %d %d" % (self.adb, self.coordinates[1][0], self.coordinates[1][-1]), status)
        #: 点击打卡
        status = self._next_cmd("%s shell input tap %d %d" % (self.adb, self.coordinates[2][0], self.coordinates[2][-1]), status, 10)
        #: 截屏并上传到PC端MiCloud云盘中
        status = self._next_cmd("%s pull /sdcard/screenshot.png C:/Users/staugur/MiCloud/drive/dtalk.png" % self.adb, self._exec_cmd("%s shell screencap -p /sdcard/DCIM/Screenshots/screenshot.png" % self.adb), 5)
        #: 关闭钉钉
        #status = self._next_cmd("%s shell am force-stop com.alibaba.android.rimet" % self.adb, status, 5)
        #: 输出
        return status, output


if __name__ == "__main__":
    # 配置
    coordinates = ((541, 1840), (140, 1392), (539, 1152))
    access_token = "e0b125311da14932571da9a53804bb0fbceda67157a8cfcd390a849d3741d0858c911afd96513562ebfe29f91d04bd454c907dff79b515887ccb09713504ba5e3c0988865fa24657671c17e7d8d1fe4f"
    # 执行
    ntime = time.strftime('%Y-%m-%d %H:%M', time.localtime(time.time()))
    stime = time.time()
    dtalk = PunchCard(coordinates=coordinates)
    status, output = dtalk.AutoIn()
    print "打卡状态:%s, 输出:%s" % (status, output)
    msgContent = "%s:打卡%s,用时%s" % (ntime, "成功" if status == 0 else "失败:" + output, "%0.2fs" % float(time.time() - stime))
    print post("https://xingkaops.starokay.com/api/msg/?action=weixin&msgType=text", dict(msgContent=msgContent), access_token)
