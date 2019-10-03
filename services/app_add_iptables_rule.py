# -*- coding: utf-8 -*-
"""
    app
    ~~~

    Iptables add rules.

    Usage:

        pip install Flask Flask-HTTPAuth

    :copyright: (c) 2019 by staugur.
    :license: BSD 3-Clause, see LICENSE for more details.
"""

from re import compile
from os import getenv
from flask import Flask, jsonify, request
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash
from subprocess import Popen, PIPE, STDOUT

app = Flask(__name__)
auth = HTTPBasicAuth()

comma_pat = compile(r"\s*,\s*")
FIU = getenv("FLUSH_IPTABLES_USERS")
if not FIU or not ":" in FIU:
    raise ValueError('Invalid environment variable: FLUSH_IPTABLES_USERS')
USERS = {
    i.split(":")[0]: generate_password_hash(i.split(':')[1])
    for i in comma_pat.split(FIU)
    if "" in i and i.split(":")[0]
}
if not USERS:
    raise ValueError('Invalid users')
ALLOWED_IPS = []


def run_cmd(*args):
    """
    Execute the external command and get its exitcode, stdout and stderr.
    """
    try:
        proc = Popen(args, stdout=PIPE, stderr=STDOUT)
    except (OSError, Exception) as e:
        out, err, exitcode = (str(e), None, 1)
    else:
        out, err = proc.communicate()
        exitcode = proc.returncode
    finally:
        return exitcode, out, err


@auth.verify_password
def verify_password(username, password):
    if username in USERS:
        return check_password_hash(USERS.get(username), password)
    return False


@app.route('/')
@auth.login_required
def index():
    ip = request.headers.get('X-Real-Ip', request.remote_addr)
    if ip in ALLOWED_IPS:
        return jsonify(dict(code=0, msg="Already allowed access"))
    code, out, err = run_cmd(
        "sudo", "iptables", "-I", "INPUT",
        "-p", "tcp", "--dport", "34567",
        "-s", ip,
        "-j", "ACCEPT"
    )
    if err:
        if not out:
            out = ''
        out += err
    if code == 0:
        ALLOWED_IPS.append(ip)
    res = dict(
        code=code,
        msg=out
    )
    return jsonify(res)


if __name__ == '__main__':
    app.run(port=13129, host='127.0.0.1')

