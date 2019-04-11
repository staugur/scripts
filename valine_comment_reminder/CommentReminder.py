#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    CommentReminder
    ~~~~~~~~~~~~~~~

    这是针对Valine评论系统（https://valine.js.org）的小功能，用以获取系统中的新增评论，并发送提醒给管理员。

    运行逻辑：

        定时检索leancloud存储的数据与本地对比，发现新增数据后发送邮件提醒。

    使用要求：

        - 您可以在Windows、Linux、Mac等系统中使用，只要求安装Python2.7环境，下载地址是https://www.python.org/download/releases/2.7/

        - 有一个可用邮箱

            - QQ邮箱，密码要求是授权码，帮助页面：https://service.mail.qq.com/cgi-bin/help?subtype=1&&id=28&&no=1001256
            - 腾讯企业邮箱，163免费企业邮箱，密码可非授权码
            - 163邮箱，未测试

    使用方法：

        - python2.7 CommentReminder.py #-h查看帮助，需要设置的信息都在选项中。

    使用示例：

        - ./CommentReminder.py --app-id YourAPPID --app-key YourAPPKey -e xxxx@qq.com -p 授权码
        - 建议加入到定时任务中，比如5分钟执行一次：*/5 * * * * python CommentReminder.py

    寻求帮助：

        - email: staugur@email.com 
        - issue: https://github.com/saintic/satic.sdi/issues

    :copyright: (c) 2019 by staugur.
    :license: BSD 3-Clause.
"""

import os
import time
import json
import shelve
import hashlib
import urllib2
import traceback
import smtplib
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
from urllib import urlencode
from tempfile import gettempdir


class SendMail(object):
    """发送邮件类"""

    def __init__(self, email, password, _type=None):
        """初始化邮箱客户端配置。

        :param: email: str: 邮箱地址
        :param: password: str: 邮箱密码或可登录的授权码
        :param: _type: str: 邮箱类型，比如qq邮箱（QQ）、163邮箱（163）、腾讯企业邮箱（QQ_EXMAIL）、163免费企业邮箱（163_YM），目前支持这四种。
                            前两种可以通过邮箱后缀域名直接判断；后两种免费企业邮箱因为允许自定义域名，所以需要通过此参数设置值。
        """
        self.useraddr = email
        self.password = password
        self.smtp_server = None
        self.smtp_port = 25
        self.smtp_ssl = False
        self.subject = u"叮咚，有新评论啦！"
        self.from_addr = self._format_addr("Valine Comment Reminder <{}>".format(self.useraddr))
        self._smtp_server_bind(_type)

    def _smtp_server_bind(self, _type=None):
        """根据email后缀绑定邮件服务器信息"""
        dn = self.useraddr.split("@")[-1]
        if dn in ("qq.com", "foxmail.com", "vip.qq.com"):
            _type = "QQ"
        elif dn in ("163.com"):
            _type = "163"
        # 您可以在这里自行扩展或直接设置_type值，下面根据_type值设置smtp_server、smtp_port等。
        if _type == "QQ":
            # QQ邮箱 - https://mail.qq.com
            self.smtp_server = "smtp.qq.com"
            self.smtp_port = 465
            self.smtp_ssl = True
        elif _type == "163":
            # 163邮箱 - https://mail.163.com
            self.smtp_server = "smtp.163.com"
        elif _type == "QQ_EXMAIL":
            # 腾讯企业邮箱 - https://exmail.qq.com
            self.smtp_server = "smtp.exmail.qq.com"
            self.smtp_port = 465
            self.smtp_ssl = True
        elif _type == "163_YM":
            # 163免费企业邮箱 - http://mail.ym.163.com
            self.smtp_server = "smtp.ym.163.com"
        else:
            raise ValueError("邮箱类型错误")

    def _format_addr(self, s):
        name, addr = parseaddr(s)
        return formataddr((Header(name, 'utf-8').encode(), addr))

    def SendMessage(self, message, formatType="html"):
        """
        发送文本/HTML消息
        @param message(str, unicode) 邮件正文
        @param formatType(str, unicode)  邮件格式类型 plain或html
        """
        res = dict(success=False)
        if message and isinstance(message, (str, unicode)):
            to_addrs = self.useraddr
            msg = MIMEText(message, formatType, 'utf-8')
            msg['From'] = self.from_addr
            msg['To'] = to_addrs
            msg['Subject'] = Header(self.subject, 'utf-8').encode()
            try:
                if self.smtp_ssl is True:
                    server = smtplib.SMTP_SSL(self.smtp_server, port=self.smtp_port)
                else:
                    server = smtplib.SMTP(self.smtp_server, port=self.smtp_port)
                # server.set_debuglevel(1)
                server.login(self.useraddr, self.password)
                server.sendmail(self.useraddr, to_addrs, msg.as_string())
                server.quit()
            except smtplib.SMTPException as e:
                traceback.print_exc()
                res.update(msg="Mail delivery failed, please try again later")
            else:
                res.update(success=True)
        else:
            res.update(msg="Bad mailbox format")
        return res


class Requests(object):

    def __init__(self, app_id, app_key):
        self._app_id = app_id
        self._app_key = app_key
        self._api_url = "https://%s.api.lncld.net/1.1/cloudQuery" % self._app_id[:8]

    def _get_timestamp(self):
        """获取13位毫秒级时间戳"""
        return int(round(time.time() * 1000))

    def _get_md5(self, msg):
        """MD5"""
        return hashlib.md5(msg).hexdigest()

    def _sign(self):
        """签名"""
        timestamp = self._get_timestamp()
        sign = self._get_md5("%s%s" % (timestamp, self._app_key))
        return "%s,%s" % (sign, timestamp)

    def make_request(self, data):
        """ 发送请求 """
        headers = {
            "User-Agent": "Mozilla/5.0 (X11; CentOS; Linux i686; rv:7.0.1406) Gecko/20100101 SaintIC/0.1.0",
            "Content-Type": "application/json",
            "X-LC-Id": self._app_id,
            "X-LC-Sign": self._sign()
        }
        request = urllib2.Request(self._api_url + "?" + urlencode(data), headers=headers)
        response = urllib2.urlopen(request)
        response = response.read()
        try:
            data = json.loads(response)
        except Exception as e:
            traceback.print_exc()
        else:
            return data


class LocalStorage(object):

    def __init__(self):
        self.index = 'valine_leancloud_dat'

    def open(self, flag="c"):
        """Open handle"""
        return shelve.open(os.path.join(gettempdir(), self.index), flag=flag, protocol=2)

    def set(self, key, value):
        """Set persistent data with shelve.

        :param key: string: Index key

        :param value: All supported data types in python

        :raises:

        :returns:
        """
        db = self.open()
        try:
            db[key] = value
        finally:
            db.close()

    @property
    def list(self):
        """list all data

        :returns: dict
        """
        try:
            data = self.open(flag="r")
        except:
            pass
        else:
            return dict(data)

    def get(self, key):
        """Get persistent data from shelve.

        :returns: data
        """
        try:
            value = self.list[key]
        except:
            return
        else:
            return value


class ProcessChange(object):

    def __init__(self, app_id, app_key):
        self.request = Requests(app_id, app_key)
        self.storage = LocalStorage()

    def _email_tpl(self, html):
        """邮件模板，HTML格式是每个tr包含4个td"""
        tpl = u'<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head><body><table style="width:550px;"><tr><td style="padding-top:10px; padding-left:5px; padding-bottom:5px; border-bottom:1px solid #D9D9D9; font-size:16px; color:#999;">Valine Comment</td></tr><tr><td style="padding:20px 0px 20px 5px; font-size:14px; line-height:23px;">叮咚！以下是新增评论信息哦！</td></tr><tr><td style="padding:0px 0px 10px 5px; font-size:14px;"><table style="border-collapse:collapse;width:100%;border:1px solid #c6c6c6!important;margin-bottom:20px"><thead style="color:green;"><tr><th style="min-width:60px;border-collapse:collapse;border-right:1px solid #c6c6c6!important;border-bottom:1px solid #c6c6c6!important;background-color:#def!important;padding:5px 9px;font-size:14px;font-weight:normal;text-align:center">用户昵称</th><th style="min-width:150px;border-collapse:collapse;border-right:1px solid #c6c6c6!important;border-bottom:1px solid #c6c6c6!important;background-color:#def!important;padding:5px 9px;font-size:14px;font-weight:normal;text-align:center">用户邮箱</th><th style="min-width:250px;border-collapse:collapse;border-right:1px solid #c6c6c6!important;border-bottom:1px solid #c6c6c6!important;background-color:#def!important;padding:5px 9px;font-size:14px;font-weight:normal;text-align:center">评论页面</th><th style="min-width:300px;border-collapse:collapse;border-right:1px solid #c6c6c6!important;border-bottom:1px solid #c6c6c6!important;background-color:#def!important;padding:5px 9px;font-size:14px;font-weight:normal;text-align:center">评论内容</th></tr></thead><tbody>' + html + u'</tbody></table></td></tr><tr><td style="padding-top:5px; padding-left:5px; padding-bottom:10px; border-top:1px solid #D9D9D9; font-size:12px; color:#999;">Powered by <a href="https://github.com/staugur" target="_blank" style="text-decoration:none;color:#787878;">staugur</a>。如有任何疑问，请提交<a href="https://github.com/saintic/satic.sdi/issues" target="_blank" style="text-decoration:none;color:#787878;">issue</a>！</td></tr></table></body></html>'
        return tpl

    def run_check(self, email, password, _type):
        """运行一次检查：获取leancloud应用存储中Comment数据并校验"""
        page = 1
        limit = 100
        origin = dict()
        while 1:
            _post_data = dict(cql="select count(*),objectId,nick,mail,url,comment,createdAt,updatedAt from Comment limit ?,? order by updatedAt", pvalues=[(page-1)*limit, limit])
            _page_data = self.request.make_request(_post_data)
            _results_data = _page_data.get("results", [])
            if not _results_data:
                break
            else:
                page += 1
                for result in _results_data:
                    origin[result["objectId"]] = result
                time.sleep(0.1)
        # 尝试获取上一次源数据及数量
        last_origin = json.loads(self.storage.get("origin") or "{}")
        last_count = len(last_origin)
        # 本次数据数量
        curr_count = len(origin)
        # 判断是否有新增评论
        if curr_count > last_count:
            # 有新增评论，获取新增了哪些，整合完成发送邮件
            html = ""
            for objectId in list(set(origin).difference(set(last_origin))):
                objectData = origin[objectId]
                style = "border-collapse:collapse;border-right:1px solid #c6c6c6!important;border-bottom:1px solid #c6c6c6!important;padding:5px 9px;font-size:12px;font-weight:normal;text-align:center;word-break:break-all"
                html += "".join([
                    '<tr><td style="' + style + '">',
                    objectData["nick"],
                    '</td><td style="' + style + '">',
                    objectData["mail"],
                    '</td><td style="' + style + '"><a href="' + objectData["url"] + '" style="text-decoration: none;color: #787878;">' + objectData["url"] + '</a>',
                    '</td><td style="' + style + '">',
                    objectData["comment"],
                    "</td></tr>"
                ])
            if html:
                sendmail = SendMail(email, password, _type)
                resp = sendmail.SendMessage(self._email_tpl(html))
                if not resp["success"]:
                    return
                else:
                    print(resp)
        # 更新源数据
        self.storage.set("origin", json.dumps(origin))


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=u"第一次使用时除了明确提示，所有选项均需要设置，但会在本地保存设置信息；\n以后若不更改无需重复设置，亦可只重新设置某一项。\n如果仍需帮助，请提交issue，https://github.com/saintic/satic.sdi/issues", formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-s", "--show-config", action='store_true', default=False, help=u"可选：仅查询已保存的配置信息。")
    parser.add_argument("--app-id", help=u"LeanCloud应用的AppID，若已设置则可忽略。")
    parser.add_argument("--app-key", help=u"LeanCloud应用的AppKey，若已设置则可忽略。")
    parser.add_argument("-e", "--email", help=u"邮箱地址，直接支持QQ、163邮箱、腾讯企业邮箱、163免费企业邮箱，若您使用后两种邮箱，请设置type选项。")
    parser.add_argument("-p", "--password", help=u"邮箱密码或授权码")
    parser.add_argument("-t", "--type", type=str, choices=["QQ", "163", "QQ_EXMAIL", "163_YM"], help=u"邮箱类型，目前支持qq邮箱（QQ）、163邮箱（163）、腾讯企业邮箱（QQ_EXMAIL）、163免费企业邮箱（163_YM）；\n若前两者，则不用设置此选项。\n如果邮箱地址是后两种，则需要显式设置此选项。")
    args = parser.parse_args()
    # 获取命令行配置
    show_config = args.show_config
    app_id = args.app_id
    app_key = args.app_key
    email = args.email
    password = args.password
    _type = args.type
    # 尝试获取已存储的配置
    storage = LocalStorage()
    setting = json.loads(storage.get("setting") or "{}")
    # 一次性命令
    if show_config:
        print(setting)
        exit(0)
    # 确定配置信息
    if not app_id:
        app_id = setting.get("app_id")
    if not app_key:
        app_key = setting.get("app_key")
    if not email:
        email = setting.get("email")
    if not password:
        password = setting.get("password")
    if not _type:
        _type = setting.get("_type")
    # 打印帮助
    if app_id and app_key and email and password:
        do = ProcessChange(app_id, app_key)
        try:
            do.run_check(email, password, _type)
        except:
            traceback.print_exc()
        else:
            storage.set("setting", json.dumps(dict(app_id=app_id, app_key=app_key, email=email, password=password, _type=_type)))
    else:
        parser.print_help()
