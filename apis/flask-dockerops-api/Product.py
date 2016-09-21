#!/usr/bin/python -O
#product environment start application with `tornado IOLoop` and `gevent server`

from api import app
from pub import logger
from pub.config import GLOBAL, PRODUCT

Host = GLOBAL.get('Host')
Port = GLOBAL.get('Port')
ProcessName = PRODUCT.get('ProcessName')
ProductType = PRODUCT.get('ProductType')

try:
    import setproctitle
except ImportError, e:
    logger.warn("%s, try to pip install setproctitle, otherwise, you can't use the process to customize the function" %e)
else:
    setproctitle.setproctitle(ProcessName)
    logger.info("The process is %s" % ProcessName)

try:
    logger.info('%s has been launched, %s:%d' %(ProcessName, Host, Port))
    if ProductType == 'gevent':
        from gevent.wsgi import WSGIServer
        http_server = WSGIServer((Host, Port), app)
        http_server.serve_forever()

    elif ProductType == 'tornado':
        from tornado.wsgi import WSGIContainer
        from tornado.httpserver import HTTPServer
        from tornado.ioloop import IOLoop
        http_server = HTTPServer(WSGIContainer(app))
        http_server.listen(Port)
        IOLoop.instance().start()

    elif ProductType == "uwsgi":
        try:
            import os
            from sh import uwsgi
            from multiprocessing import cpu_count
            BASE_DIR= os.path.dirname(os.path.abspath(__file__))
            logfile = os.path.join(BASE_DIR, 'logs', 'uwsgi.log')
            if os.path.exists('uwsgi.ini'):
                uwsgi("--http", "%s:%d"%(Host,Port), "--procname-master", ProcessName, "--procname", ProcessName + ".worker", "--chdir", BASE_DIR, "-w", "api:app", "-d", logfile, "-M", "-p", cpu_count(), "--ini", "uwsgi.ini")
            else:
                uwsgi("--http", "%s:%d"%(Host,Port), "--procname-master", ProcessName, "--procname", ProcessName + ".worker", "--chdir", BASE_DIR, "-w", "api:app", "-d", logfile, "-M", "-p", cpu_count())
        except ImportError:
            errmsg=r"Start Fail, maybe you did not install the `sh` module."
            logger.error(errmsg)
            raise ImportError(errmsg)

    else:
        errmsg='Start the program does not support with %s, abnormal exit!' %ProductType
        logger.error(errmsg)
        raise RuntimeError(errmsg)

except Exception,e:
    print(e)
    logger.error(e)
