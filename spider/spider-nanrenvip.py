# -*- coding: utf-8 -*-
import urllib
import urllib2
import sys
import re
import os
reload(sys)
sys.setdefaultencoding('utf-8')


class AVNY(object):
    def __init__(self,baseurl,newurl):
        self.URL = baseurl
        self.NEWURL = newurl

    def getPage(self):
        #获取首页
        user_agent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.3226.400 QQBrowser/9.6.11681.400'
        headers = {'user_agent':user_agent}
        request = urllib2.Request(self.URL,headers=headers)
        reponse = urllib2.urlopen(request)
        page = reponse.read().decode('utf-8')
        return page

    def getName(self,page):
        #获取女优名字
        pattern = re.compile(r'<div class="well_tit.*?<h1>(.*?)</h1>',re.S)
        title = re.search(pattern,page)
        return title.group(1)

    def getAbstract(self,page):
        #获取女优简介
        pattern = re.compile(r'<div class="well_tit.*?<.*?"avms">(.*?)</p>',re.S)
        abstract = re.search(pattern,page)
        return abstract.group(1)

    def getNewUrls(self,page):
        #获取年份作品链接
        pattern = re.compile(r'<button.*?><a href="(.*?)">.*?</a></button>',re.S)
        NewUrls = re.findall(pattern,page)
        return NewUrls

    def getNewPage(self,url):
        #读取年份作品链接页面
        user_agent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.104 Safari/537.36 Core/1.53.3226.400 QQBrowser/9.6.11681.400'
        headers = {'user_agent':user_agent}
        request = urllib2.Request(url,headers=headers)
        reponse = urllib2.urlopen(request)
        newpage = reponse.read().decode('utf-8')
        return newpage

    def getMessages(self,newpage):
        #获取年份作品具体信息
        pattern = re.compile(r'<div class="list_text">.*?<a href.*?[0-9]/(.*?).html">.*?<date>(.*?)</date><p>(.*?)</p>',re.S)
        Messages = re.findall(pattern,newpage)
        contents = []
        for message in Messages:
            contents.append(" ___ ".join([message[0],message[1],message[2]]))
        return contents

    def saveBrief (self,page):
        #将女优名字，作品信息写入文档
        filename = self.getName(page)+'.txt'
        abstract = self.getAbstract(page)
        txt = open(filename,"w")
        txt.write(abstract)
        txt.write('\n')

        for Newurl in self.getNewUrls(page):
            digiturl = self.NEWURL+Newurl
            newpage = self.getNewPage(digiturl)
            line = self.getMessages(newpage)
            for i in line:
                txt.write(i)
                txt.write('\n')
        txt.close()
        print "txt is done"

    def getImg(self,newpage):
        #获取年份作品下的图片及番号，并以番号为key，对应图片链接为value，保存为字典
        pattern = re.compile(r'<img data-original="(.*?)"></a></span>.*?<div class="list_text">.*?<a href.*?[0-9]/(.*?).html">',re.S)
        IMG = re.findall(pattern,newpage)
        IMGS = {}
        for i in IMG:
            IMGS[i[1]]=i[0]
        return IMGS

    def mkdir(self,path):
        path=path.strip()
        path=path.rstrip("\\")
        isExists=os.path.exists(path)
        if not isExists:
            os.makedirs(path) 
            print path+' 创建成功'
            return True
        else:
            print path+' 目录已存在'
            return False

    def saveIMGs(self,page,newpage):
        #保存图片函数
        mkpath=os.path.join(os.getcwd(),self.getName(page))
        self.mkdir(mkpath)
        IMGS = self.getImg(newpage)
        for ImgName in IMGS:
            ImgUrl = IMGS[ImgName]
            name = os.path.join(mkpath,ImgName + ".jpg")
            urllib.urlretrieve(ImgUrl, name)
            print name,"is done"
        print ' one year is done '

    def saveAllImgs(self,page):
        #保存所有链接内图片
        for Newurl in self.getNewUrls(page):
            digiturl = self.NEWURL+Newurl
            newpage = self.getNewPage(digiturl)
            self.saveIMGs(page,newpage)

    def strat(self):
        #启动函数
        page = self.getPage()
        self.saveBrief(page)
        self.saveAllImgs(page)

baseurl = 'http://nanrenvip.org/baishimolinai'
newurl = "http://nanrenvip.org"
S = AVNY(baseurl,newurl)
S.strat()
