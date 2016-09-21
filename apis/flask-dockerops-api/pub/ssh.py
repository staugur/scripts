# -*- coding: utf8 -*-

import gevent
import paramiko
from config import SSH
from tool import logger, ip_check
try:
    import cStringIO as StringIO
except ImportError:
    import StringIO

__doc__ = "SSH Connect Server Module"


def ssh2(**kwargs):
    """
    Paramiko based on the SSH connection function, the parameters are as follows:
    1.ip(str),remote machine ip;
    2.port(int),remote machine ssh port, default is 20002;
    3.username(str),remote machine username, default is in config.py(SSH USERNAME);
    4.passwd(str),remote machine username's password(or private key password), default is in config.py(SSH PASSWD);
    5.pkey(str),remote machine username's private key, default is in config.py(SSH PRIVATE_KEY);
    6.cmd(str),a command to execute on a remote machine, it can be a list or tuple, exec all of cmd.
    """
    _USERNAME        = SSH.get("USERNAME")
    _PRIVATE_KEY_PWD = SSH.get("PASSWD")
    _PRIVATE_KEY     = SSH.get("PRIVATE_KEY")
    _TIMEOUT         = SSH.get("TIMEOUT", 5)

    res = []
    try:
        ip       = kwargs.get("ip")
        cmd      = kwargs.get("cmd")
        port     = kwargs.get("port", 20002)
        username = kwargs.get("username", _USERNAME)
        pkey     = paramiko.RSAKey.from_private_key(StringIO.StringIO(kwargs.get("pkey", _PRIVATE_KEY)), kwargs.get("passwd", _PRIVATE_KEY_PWD))
        cmd      = kwargs.get("cmd")

        #check args
        if ip_check(ip) == None:
            return "IP(%s) format error, ssh2 exit!" %ip

        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip, port, username, pkey=pkey, timeout=_TIMEOUT)

        init_cmd = 'source /etc/profile ; source ~/.bash_profile'
        if isinstance(cmd, (list, tuple)):
            for command in cmd:
                init_cmd = init_cmd + ' ; ' + command
            cmd = init_cmd
            logger.debug("cmd is a list or tuple, split it.")
        else:
            cmd = init_cmd + ' ; ' + cmd

        stdin, stdout, stderr = ssh.exec_command(cmd)
        for r in stdout.readlines():
            _r = r.strip("\n")
            logger.debug(_r)
            res.append(_r)

        ssh.close()
    except Exception,e:
        logger.error(e)
    logger.info("SSH Connect %s:%d, with %s, exec => %s, res ==> %s" %(ip, port, username, cmd, res))
    return res

def ssh2_async_coroutine(cmd, ips):
    if not ips and not isinstance(ips, (list, tuple)):
        return "No ips or type error."
    if not cmd:
        return "No cmd"        
    res = []
    for ip in ips:
        logger.info("Func ssh2_async_coroutine connect %s, exec ==> %s, then coroutine." %(ip, cmd))
        res.append(ssh2(ip=ip, cmd=cmd))
        gevent.sleep(0)
    return res

def ssh2_async_thread(name=None, *ips):
    thread_list=[]
    for ip in ips:
        thread_list.append(Thread(target=ssh2, args=(ip, cmds), name="ssh worker"))
    for p in thread_list:
        p.start()
    for p in thread_list:
        p.join()
    for ip in ips:
        threads.append(gevent.spawn(Update,i))
    gevent.joinall(threads)
    logger.debug(threads)
    return ''

def ssh2_yeild():
    pass