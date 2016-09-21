#!/usr/bin/python
# -*- coding: UTF-8 -*-

import smtplib
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.header import Header

def SendMailPic(*images, **kw):
    sender  = kw.get("sender")
    to      = kw.get("to")
    subject = kw.get("subject")
    debug   = kw.get("debug")
    if not isinstance(images, (list, tuple)):raise TypeError("images is a list or tuple for [img1, img2, ...]")
    if debug and not isinstance(debug, int):raise TypeError("debug ask a number")

    msg = MIMEMultipart('related')
    if not sender: sender  = "taochengwei"
    if not subject:subject = 'Everyday Pics for Beautiful!'
    if not to:     to      = "staugur@vip.qq.com"
    msg['From'] = Header(str(sender), 'utf-8')
    msg['To'] =  Header(to, 'utf-8')
    msg['Subject'] = Header(subject, 'utf-8')

    msgAlternative = MIMEMultipart('alternative')
    msg.attach(msgAlternative)

    content = """<center><h1>每时美图</h1></center>"""
    imgId=0
    for img in images:
        if isinstance(img, (list, tuple)): raise TypeError(type(img))
        # 指定图片为当前目录
        fp = open(img, 'rb')
        msgImage = MIMEImage(fp.read())
        fp.close()
        # 定义图片 ID，在 HTML 文本中引用
        msgImage.add_header('Content-ID', '<%d>'%imgId)
        msg.attach(msgImage)
        content+="""<p><img src="cid:%d"></p>"""%imgId
        imgId+=1
    msgAlternative.attach(MIMEText(content, 'html', 'utf-8'))

    try:
        server = smtplib.SMTP('mail.emar.com', 25)
        if debug:
            server.set_debuglevel(int(debug))
        else:
            pass
        server.login("taochengwei@emar.com", "zxgtEQXTFDF7")
        server.sendmail(sender, to, msg.as_string())
        server.quit()
        return 0
    except smtplib.SMTPException:
        return 1

if  __name__ == "__main__":
    test=['1.jpg', '2.jpg']
    print SendMailPic(*test)
