# -*- coding: utf-8 -*-

import os
import sys
import requests
import xmltodict
from six.moves import queue as Queue
from threading import Thread
import re
import json


# 设置请求超时时间
TIMEOUT = 10

# 尝试次数
RETRY = 5

# 分页请求的起始点
START = 0

# 每页请求个数
MEDIA_NUM = 1000

# 并发线程数
THREADS = 10

# 是否下载图片
ISDOWNLOADIMG=True

#是否下载视频
ISDOWNLOADVIDEO=True


class DownloadWorker(Thread):
    def __init__(self, queue, proxies=None):
        Thread.__init__(self)
        self.queue = queue
        self.proxies = proxies

    def run(self):
        while True:
            medium_type, post, target_folder = self.queue.get()
            self.download(medium_type, post, target_folder)
            self.queue.task_done()

    def download(self, medium_type, post, target_folder):
        try:
            medium_url = self._handle_medium_url(medium_type, post)
            if medium_url is not None:
                self._download(medium_type, medium_url, target_folder)
        except TypeError:
            pass

    def _handle_medium_url(self, medium_type, post):
        try:
            if medium_type == "photo":
                return post["photo-url"][0]["#text"]

            if medium_type == "video":
                video_player = post["video-player"][1]["#text"]
                hd_pattern = re.compile(r'.*"hdUrl":("([^\s,]*)"|false),')
                hd_match = hd_pattern.match(video_player)
                try:
                    if hd_match is not None and hd_match.group(1) != 'false':
                        return hd_match.group(2).replace('\\', '')
                except IndexError:
                    pass
                pattern = re.compile(r'.*src="(\S*)" ', re.DOTALL)
                match = pattern.match(video_player)
                if match is not None:
                    try:
                        return match.group(1)
                    except IndexError:
                        return None
        except:
            raise TypeError("找不到正确的下载URL "
                            "请到 "
                            "https://github.com/xuanhun/tumblr-crawler"
                            "提交错误信息:\n\n"
                            "%s" % post)

    def _download(self, medium_type, medium_url, target_folder):
        medium_name = medium_url.split("/")[-1].split("?")[0]
        if medium_type == "video":
            if not medium_name.startswith("tumblr"):
                medium_name = "_".join([medium_url.split("/")[-2],
                                        medium_name])

            medium_name += ".mp4"

        file_path = os.path.join(target_folder, medium_name)
        if not os.path.isfile(file_path):
            print("Downloading %s from %s.\n" % (medium_name,
                                                 medium_url))
            retry_times = 0
            while retry_times < RETRY:
                try:
                    resp = requests.get(medium_url,
                                        stream=True,
                                        proxies=self.proxies,
                                        timeout=TIMEOUT)
                    with open(file_path, 'wb') as fh:
                        for chunk in resp.iter_content(chunk_size=1024):
                            fh.write(chunk)
                    break
                except:
                    # try again
                    pass
                retry_times += 1
            else:
                try:
                    os.remove(file_path)
                except OSError:
                    pass
                print("Failed to retrieve %s from %s.\n" % (medium_type,
                                                            medium_url))


class CrawlerScheduler(object):

    def __init__(self, sites, proxies=None):
        self.sites = sites
        self.proxies = proxies
        self.queue = Queue.Queue()
        self.scheduling()
      

    def scheduling(self):
        # 创建工作线程
        for x in range(THREADS):
            worker = DownloadWorker(self.queue,
                                    proxies=self.proxies)
            #设置daemon属性，保证主线程在任何情况下可以退出
            worker.daemon = True
            worker.start()

        for site in self.sites:
            if ISDOWNLOADIMG:
                self.download_photos(site)
            if ISDOWNLOADVIDEO:
                self.download_videos(site)
        

    def download_videos(self, site):
        self._download_media(site, "video", START)
        # 等待queue处理完一个用户的所有请求任务项
        self.queue.join()
        print("视频下载完成 %s" % site)

    def download_photos(self, site):
        self._download_media(site, "photo", START)
         # 等待queue处理完一个用户的所有请求任务项
        self.queue.join()
        print("图片下载完成 %s" % site)

    def _download_media(self, site, medium_type, start):
        current_folder = os.getcwd()
        target_folder = os.path.join(current_folder, site)
        if not os.path.isdir(target_folder):
            os.mkdir(target_folder)

        base_url = "http://{0}.tumblr.com/api/read?type={1}&num={2}&start={3}"
        start = START
        while True:
            media_url = base_url.format(site, medium_type, MEDIA_NUM, start)
            response = requests.get(media_url,
                                    proxies=self.proxies)
            data = xmltodict.parse(response.content)
            try:
                posts = data["tumblr"]["posts"]["post"]
                for post in posts:
                    # select the largest resolution
                    # usually in the first element
                    self.queue.put((medium_type, post, target_folder))
                start += MEDIA_NUM
            except KeyError:
                break


def usage():
    print(u"未找到sites.txt文件，请创建.\n"
          u"请在文件中指定Tumblr站点名，并以逗号分割，不要有空格.\n"
          u"保存文件并重试.\n\n"
          u"例子: site1,site2\n\n"
          u"或者直接使用命令行参数指定站点\n"
          u"例子: python tumblr-photo-video-ripper.py site1,site2")


def illegal_json():
    print(u"文件proxies.json格式非法.\n"
          u"请参照示例文件'proxies_sample1.json'和'proxies_sample2.json'.\n"
          u"然后去 http://jsonlint.com/ 进行验证.")


if __name__ == "__main__":
    sites = None

    proxies = None
    if os.path.exists("./proxies.json"):
        with open("./proxies.json", "r") as fj:
            try:
                proxies = json.load(fj)
                if proxies is not None and len(proxies) > 0:
                    print("You are using proxies.\n%s" % proxies)
            except:
                illegal_json()
                sys.exit(1)

    if len(sys.argv) < 2:
        #校验sites配置文件
        filename = "sites.txt"
        if os.path.exists(filename):
            with open(filename, "r") as f:
                sites = f.read().rstrip().lstrip().split(",")
        else:
            usage()
            sys.exit(1)
    else:
        sites = sys.argv[1].split(",")

    if len(sites) == 0 or sites[0] == "":
        usage()
        sys.exit(1)

    CrawlerScheduler(sites, proxies=proxies)
