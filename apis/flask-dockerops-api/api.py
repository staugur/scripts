# -*- coding:utf-8 -*-

import time
import json
import types
import requests
from pub import logger, gen_requestId, config, ECSS, DOCKER_CMD, ip_check
from flask import Flask, request, g, redirect, jsonify, url_for
from flask_restful import Api, Resource
from multiprocessing.dummy import Pool as ThreadPool 

__author__  = 'Mr.tao'
__doc__     = 'Flask Api for Emarsys dockerops'
__date__    = '2016-07-01'
__version__ = '0.2.2'

app = Flask(__name__)
api = Api(app)

#每个URL请求之前，定义requestId并绑定到g.
@app.before_request
def before_request():
    g.requestId = gen_requestId()
    logger.info("Start Once Access, and this requestId is %s" % g.requestId)

#每次返回数据中，带上响应头，包含API版本和本次请求的requestId，以及允许所有域跨域访问API, 记录访问日志.
@app.after_request
def add_header(response):
    response.headers["Content-type"]      = "application/json, charset=utf8;"
    response.headers["X-Emar-Media-Type"] = "Version %s" % __version__
    response.headers["X-Emar-Request-Id"] = g.requestId
    response.headers["Access-Control-Allow-Origin"] = "*"
    logger.info(json.dumps({
        "AccessLog": {
            "status_code": response.status_code,
            "method": request.method,
            "ip": request.headers.get('X-Real-Ip', request.remote_addr),
            "url": request.url,
            "referer": request.headers.get('Referer'),
            "agent": request.headers.get("User-Agent"),
            "requestId": g.requestId,
            }
        }
    )) 
    return response

#自定义错误显示信息，404错误和500错误
@app.errorhandler(404)
def not_found(error=None):
    message = {
        'code': 404,
        'msg': 'Not Found: ' + request.url,
    }
    resp = jsonify(message)
    resp.status_code = 404
    return resp

@app.errorhandler(500)
def internal_error(error=None):
    message = {
        'code': 500,
        'msg': 'Internal Server Error: ' + request.url,
    }
    resp = jsonify(message)
    resp.status_code = 500
    logger.CRITICAL(resp)
    return resp

class Index(Resource):

    def get(self):
        return {"Hello": "flask-dockerops-api"}

class Project(Resource):

    @classmethod
    def get(self):
        url = "http://172.16.25.117:10010/getallproject/"
        return requests.get(url).json()

    @classmethod
    def post(self):
        try:
            project_id = request.json.get("project_id")
            tag       = request.json.get("tag")
        except Exception,e:
            logger.warn(e)
            project_id = request.form.get("project_id")
            tag       = request.form.get("tag")
        if not isinstance(project_id, int) or not project_id or not tag:
            res = {"project_id": project_id, "tag": tag, "errmsg": "project_id or tag error"}
            logger.error(res)
            return res
        url = "http://172.16.25.117:10010/update_project_tag/"
        res = requests.post(url, data={"project_id": project_id, "tags": tag})
        logger.debug({"requestId": requestId, "action": "post a request for change project(id=%d) tag(%s) to %s"%(project_id, tag, url), "result": res.text, "code": res.status_code})
        return res.json()

class Etcd(Resource):

    @classmethod
    def get(self):
        ec   = ECSS(etcd_host = config.ETCD.get("ETCD_HOST"), etcd_port = config.ETCD.get("ETCD_PORT"), etcd_scheme = config.ETCD.get("ETCD_SCHEME"))
        st   = time.time()
        res  = {"code": 0, "msg": None, "data": None}
        _etcd= lambda (req):ec.get_all_keys(req=req)

        """Request Query Parameters"""
        etcd_keys = request.args.get("etcd_keys", False)
        etcd_ips  = request.args.get("etcd_ips", False)

        if etcd_keys == "true" or etcd_keys == True:
            etcd_keys = True
        if etcd_ips == "true" or etcd_ips == True:
            etcd_ips = True
        try:
            if not etcd_keys and not etcd_ips:
                res.update({"msg": "Hello, " + url_for("etcd")})
            else:
                if etcd_ips == True:
                    data = list(_etcd("ip"))
                    res["msg"] = "get etcd all ip in keys"
                else:
                    if etcd_keys == True:
                        data = list(_etcd("key"))
                        res["msg"] = "get etcd all keys"
                    else:
                        data = []
                        res["msg"] = "Query parameter error"
                        res["code"]= 32001
                res["data"] = data
        except Exception,e:
            logger.error(e)
            res.update({"data": [], "msg": "Server Exception, Please feedback to the administrator.", "code": 32002})
        logger.info('Get %s, runs %0.2f seconds.' % (url_for("etcd"), time.time() - st))
        return res

class Docker(Resource):

    @classmethod
    def get(self):
        st   = time.time()
        res  = {"code": 0, "msg": None, "data": None}

        """Request Query Parameters"""
        ip = request.args.get("ip")
        ip_from = request.args.get("ip_from")
        #images   = request.args.get("images", False)
        containers    = request.args.get("containers", False)
        containers_all  = request.args.get("containers_all", False)

        if not ip and not ip_from:
            res.update({"msg": "Hello, " + url_for("docker")})
            logger.info(res)
            return res
        else:
            if ip:
                if ip_check(ip) == None or ip in ("127.0.0.1", "0.0.0.0", "255.255.255.255"):
                    res.update({"msg": "Query parameter error for ip, invalid IP address.", "code": 33002})
                    logger.info(res)
                    return res
                else:
                    ips = (ip,)
            else:
                if ip_from and ip_from in ("etcd",):
                    ec  = ECSS(etcd_host = config.ETCD.get("ETCD_HOST"), etcd_port = config.ETCD.get("ETCD_PORT"), etcd_scheme = config.ETCD.get("ETCD_SCHEME"))
                    ips = tuple(ec.get_all_keys(req="ip"))
                    logger.info("ip_from is %s, get etcd ips is %s" %(ip_from, ips))
                else:
                    res.update({"msg": "Query parameter error for ip_from", "code": 33003})
                    logger.info(res)
                    return res
        if containers == "true" or containers == "True":
            containers = True
        if containers_all == "true" or containers_all == "True":
            containers_all = True

        if containers == True:
            l = len(ips)
            if l <= 4:
                workers = 1
            elif l <= 10:
                workers = 4
            elif l <= 30:
                workers = 6
            elif l <= 50:
                workers = 8
            elif l <= 80:
                workers = 12
            else:
                workers = 16
            dock = lambda ip:DOCKER_CMD(ip).Containers(All=containers_all)
            try:
                pool = ThreadPool(processes=workers)
                logger.debug("start multiprocessing.dummy map(map_async), processes is %d" %workers)
                logger.debug(ips)
                data = pool.map(dock, ips)
                pool.close()
                pool.join()
                #data = pool.map_async(dock, ips).get()
                if isinstance(data, list) and len(data) == 1:
                    data = data[0]
            except Exception,e:
                logger.error(e)
                res.update({"msg": "connect server error, get data null", "code": 33004})
            else:
                res.update({"data": data, "msg": "get containers, all is %s." %containers_all})
        else:
            res["msg"] = "Query parameter error, at least containers(bool) is true."
            res["code"]= 33005
        logger.info('Get %s, runs %0.2f seconds' % (url_for("docker"), time.time() - st))
        return res

#Router rules
api.add_resource(Index, '/', endpoint='index')
api.add_resource(Etcd, '/etcd', '/etcd/', endpoint='etcd')
api.add_resource(Docker, '/docker', '/docker/', endpoint='docker')
api.add_resource(Project, '/project', '/project/', endpoint='project')

if __name__ == '__main__':
    from pub.config import GLOBAL
    Host  = GLOBAL.get('Host')
    Port  = GLOBAL.get('Port')
    Debug = GLOBAL.get('Debug', True)
    app.run(host=Host, port=int(Port), debug=Debug)