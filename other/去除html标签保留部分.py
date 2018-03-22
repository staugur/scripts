# coding: utf8

import bleach, re, sys
from flask import Flask,render_template

app=Flask(__name__)

@app.route("/")
def index():
    s = "<scan>注意:</scan>处理<a href='https://abc.com/user/req' title='描述' style='color:red;font-size: 99px'>&nbsp;&nbsp;用户请求</a><br/><abbr title='英文字母表'>abcdefg</abbr><blockquote>blockquote</blockquote><hr><img src='/static/images/vip.png' alt='vip' title='vip' />"
    data = bleach.clean(s, tags=[u'a', u'abbr', u'acronym', u'b', u'blockquote', u'code', u'em', u'i', u'strong', u'img'], attributes={u'a': [u'href', u'title'], u'acronym': [u'title'], u'abbr': [u'title'], u'img': [u'title', u'alt', u'src', u'width', u'height'], u'*': [u'style']}, styles=['color'])
    return render_template("index.html", data=data)

app.run(debug=True)