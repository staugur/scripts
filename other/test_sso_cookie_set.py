#coding:utf8

import datetime,time
def ISOString2Time(s):
    ''' 
    convert a ISO format time to second
    from:2006-04-12 to:23123123
    '''
    import time
    d = datetime.datetime.strptime(s,"%Y-%m-%d")
    return time.mktime(d.timetuple()) - time.time()

t="2016-12-02"
print ISOString2Time(t)

from flask import Flask,make_response,request
app=Flask(__name__)

@app.route("/")
def index():
    if request.cookies.get("test") == "ok":
        return "logged_in"
    else:
        return "not logged_in"

@app.route("/login")
def login():
    resp=make_response("hello")
    resp.set_cookie(key="test", value="ok", expires=datetime.datetime.strptime(t,"%Y-%m-%d"))
    #resp.set_cookie(key='test', value="ok", max_age=ISOString2Time(t))
    return resp

app.run(debug=True)