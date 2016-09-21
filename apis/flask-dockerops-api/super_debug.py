# -*- coding:utf8 -*-
# 性能优化模式(Maybe Only Linux)

if __name__ == "__main__":
    from api import app
    from werkzeug.contrib.profiler import ProfilerMiddleware
    from pub.config import GLOBAL
    Host = GLOBAL.get('Host')
    Port = GLOBAL.get('Port')
    app.config['PROFILE'] = True
    app.wsgi_app = ProfilerMiddleware(app.wsgi_app, restrictions = [60])
    app.run(debug=True, host=Host, port=Port)
