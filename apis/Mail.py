#!/usr/bin/env python
#-*- coding=utf8 -*-

from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr,formataddr
import smtplib, re

class Error(Exception):
    pass

class ArgError(Error):
    pass

class MailError(Error):
    pass

class EMail:


    def __init__(self, FromAddr, Password, SmtpServer, SmtpPort, ToAddr, Debug=None):
        """
        FromAddr: 发件人邮箱;
        SmtpServer: 邮箱服务器;
        Password: 发件人邮箱登录密码;
        ToAddr: 收件人邮箱;
        Debug: 开启Debug模式，级别是1-7.
        """
        MailCheck = re.compile(r'([0-9a-zA-Z\_*\.*\-*]+)@([a-zA-Z0-9\-*\_*\.*]+)\.([a-zA-Z]+$)')
        if not MailCheck.match(FromAddr) or not MailCheck.match(ToAddr):
            raise MailError('Mail format error')

        if Debug != None:
            if not type(Debug) is int:
                raise TypeError("Debug is num(for debug level, eg:1)")

        self.FromAddr   = FromAddr
        self.SmtpServer = SmtpServer
        self.SmtpPort   = SmtpPort
        self.Password   = Password
        self.ToAddr     = ToAddr
        self.Debug      = Debug

    def _format_addr(self, s):
        name, addr = parseaddr(s)
        return formataddr((Header(name, 'utf-8').encode(), addr))

#构造图片
    fp = open('slt.jpg','rb')
    msgImage = MIMEImage(fp.read())
    fp.close()
    msgImage.add_header('Content-ID','<meinv_image>')
    msg.attach(msgImage)
 

    def send(self, subject, content, **kw):
        name   = kw.get('name', 'SaintIC')
        ToAddr = kw.get('to', self.ToAddr)
        Debug  = kw.get('Debug', self.Debug)
        msg = MIMEText(content, 'plain', 'utf-8')
        msg['From'] = self._format_addr('%s <%s>' % (name, self.FromAddr))
        msg['To'] = self._format_addr('%s <%s>' % (ToAddr, ToAddr))
        msg['Subject'] = Header(subject, 'utf-8').encode()
        server=smtplib.SMTP(self.SmtpServer, self.SmtpPort)
        if Debug:
            server.set_debuglevel(Debug)
        server.login(self.FromAddr, self.Password)
        server.sendmail(self.FromAddr, [ToAddr], msg.as_string())
        server.quit()

if __name__ == '__main__':
    import sys
    email=EMail(FromAddr='postmaster@saintic.net', Password='SaintAugur910323', SmtpServer='smtp.saintic.net', ToAddr='staugur@saintic.com', SmtpPort=25)
    #email=EMail(FromAddr='staugur@vip.qq.com', Password='SDI.Saint910323', SmtpServer='smtp.qq.com', SmtpPort=465, ToAddr='staugur@saintic.com', Debug=2)
    args=sys.argv
    try:
        msg = args[2]
    except IndexError:
        msg = 'Test My Mail Python 程序'
    try:
        to = args[1]
    except IndexError:
        to = 'staugur@vip.qq.com'
    print args,to,msg
    email.send('This is Subject!!!', msg, to=to, Debug=1)

