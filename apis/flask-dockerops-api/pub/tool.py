# -*- coding:utf8 -*-

import re
import hashlib
import binascii, os, uuid
from log import Syslog

md5           = lambda pwd:hashlib.md5(pwd).hexdigest()
logger        = Syslog.getLogger()
gen_token     = lambda :binascii.b2a_base64(os.urandom(24))[:32]
gen_requestId = lambda :str(uuid.uuid4())

def ip_check(ip):
    pat = re.compile(r"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
    if isinstance(ip, (str, unicode)):
        return pat.match(ip)

def parse_query(url):
    return urlparse.parse_qs(urlparse.urlparse(url).query)
