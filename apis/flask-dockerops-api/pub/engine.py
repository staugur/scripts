# -*- coding:utf8 -*-

from tool import ip_check, logger
from ssh import ssh2
import json

class DOCKER_CMD:

    """封装所需要的获取docker的信息类，基于ssh2函数和docker命令"""

    def __init__(self, ip, Coroutine=False):
        if ip_check(ip) == None:
            logger.error("IP format error, set it None.")
            ip = None
        self.ip = ip

    def Containers(self, All=False, Inspect=True):
        """
        1.All(bool), 默认为False，即只获取docker ps显示的结果(一般为Up状态的); 当为True时，获取所有容器，即docker ps -a显示的结果.
        2.Inspect(bool)，默认为False，即不查询容器的信息，当为True时，直接查询信息，返回json串。
        """
        cmd = """for cid in $(docker ps | grep -v CONTAINER | awk '{print $1}'); do docker inspect -f {'"Cid": {{json .Id }}, "Cname": {{json .Name }}, "State": {{json .State.Running }}, "StartedAt": {{json .State.StartedAt }}, "Volumes": {{json .HostConfig.Binds }}, "ImageId": {{json .Image }}, "ImageName": {{json .Config.Image }}'} $cid ; done"""
        data= []
        if Inspect == True:
            #The result to exec `cmd` is json format.
            if All == True:
                cmd = """for cid in $(docker ps -a | grep -v CONTAINER | awk '{print $1}'); do docker inspect -f {'"Cid": {{json .Id }}, "Cname": {{json .Name }}, "State": {{json .State.Running }}, "StartedAt": {{json .State.StartedAt }}, "Volumes": {{json .HostConfig.Binds }}, "ImageId": {{json .Image }}, "ImageName": {{json .Config.Image }}'} $cid ; done"""
            try:
                for _d in ssh2(ip=self.ip, cmd=cmd):
                    d=json.loads(_d)
                    logger.debug(d)
                    d["ImageId"]  = d.get("ImageId").split(":")[-1]
                    d["Cname"]    = d.get("Cname").split("/")[-1]
                    if d.get("ImageName").find(":") > 0:
                        tag = d.get("ImageName").split(":")[-1]
                    else:
                        tag = "latest"
                    d["ImageTag"]  = tag
                    data.append(d)
                #return a list, length is container number.
            except Exception,e:
                logger.error(e)
        else:
            pass
        logger.info({"action": "get Containers", "ip": self.ip, "command": cmd, "enable inspect": Inspect, "enable all": All})
        return data

    def Images(self, image=None):
        """
        1.image(str), 当image存在时，查询匹配image长度的镜像信息，否则查询IP上所有镜像信息(docker images)。
        """
        result = []
        if image:
            #simple image info
            cmd = """docker images | grep %s | awk '{print $1":"$2,$3}'""" %image
        else:
            #default get all images in remote ip machine
            #result format is => image:tag imageId
            cmd = """docker images | grep -v REPOSITORY |awk '{print $1":"$2,$3}'"""
        for image in ssh2(ip=self.ip, cmd=cmd):
            logger.debug("image is %s"%image)
            result.append({
                "image"    : image.split()[0],
                "imageId"  : image.split()[-1],
                "imageName": image.split()[0].split(":")[0],
                "imageTag" : image.split()[0].split(":")[-1],
            })
        logger.debug({"action": "get Images", "done": result})
        return result