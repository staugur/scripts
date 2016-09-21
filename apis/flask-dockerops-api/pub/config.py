# -*- coding:utf8 -*-

#全局配置端
GLOBAL={

    "Host": "0.0.0.0",
    #Application run network address, you can set it `0.0.0.0`, `127.0.0.1`, ``, `None`;
    #Default run on all network interfaces.

    "Port": 10010,
    #Application run port, default port;

    "Debug": True,
    #The development environment is open, the production environment is closed, which is also the default configuration.

    "LogLevel": "DEBUG",
    #应用程序写日志级别，目前有DEBUG，INFO，WARNING，ERROR，CRITICAL

}

#生产环境配置段
PRODUCT={

    "ProcessName": "flask-dockerops-api",
    #Custom process, you can see it with "ps aux|grep ProcessName".

    "ProductType": "tornado",
    #生产环境启动方法，可选`gevent`, `tornado`, `uwsgi`,其中tornado log level是WARNNING，也就是低于WARN级别的日志不会打印或写入日志中。
}

#etcd配置段
ETCD={
    
    "ETCD_SCHEME": "http",
    #etcd RESTfulAPI 访问协议

    "ETCD_HOST": "221.122.127.163",
    #etcd主机地址

    "ETCD_PORT": 10020,
    #etcd主机端口

    "ETCD_VERSION": "v2",
    #etcd服务版本

}

#dockerops配置段

#ssh配置段
SSH={
    "USERNAME": 'deployer',
    #ssh 用户名

    "PRIVATE_KEY": '''\
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,60716735D0F44986

jQZ7POONGlaSK/NuiJdWM7pmyaQY6WcczdobJsJwef7Uwg1Oxb6FAc6tvIw0HBLD
/XkvxRkNhi+SPG7yW5ApRRlN9UbxwOigy8FQVyB7A0SAEU+3bHTfEfQtcigKnwnM
F/70buUyGCMqlcWHEkOQPyw0tzt9HbvamN28FCoOnCL1POomPIoT4R4dGmmrYDZ3
nOvY+NDI7Yy7VsXbF03QZea/75foEqOzVHSjGNowZQ/5oGiuK63SSkjkzoW+FcXy
R0347kX3I4AFFr5p0QQdC9/hC5oXSRuW2Rou3Jtq4Xrn/kdAVSv8oCixAHbxdWCQ
j0wpU3prhwzZMhWtHrBIncVQIfZn8qkwnHDnKrFNmOVCWTpE0Jm0dEpibiMThk1C
idQNjQ6kj1Z2XTrDYT8OBV51zJlPi78NqtJ9ojaZUvWtYAJUL+yPzkW33T6Iyer4
cYs0OAusinaqtGMZoTJx+0K83NSj8VHlOqSbdUs7RZDtCuKzDDFa4h4YQdjvAaKj
M+7IMJggeScqm/HSVqEmc1SMJvl/0IxVutJ7y4icxVtZoYLUd/pOfGTP+knYhpEb
b/zIvcNyPuLFi7ZcakeMVyH/pSYBliNWKiQU+7yOkjk=
-----END RSA PRIVATE KEY-----\
''',
    #ssh USERNAME配置项的用户私钥

    "PASSWD": '!UCadIJiv0aVmRS',
    #ssh USERNAME配置项的用户私钥的加密口令(当非密钥登录，此项为用户密码)

    "TIMEOUT": 5,
    #ssh超时时间设定
}
