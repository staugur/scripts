# -*- coding: utf-8 -*-

import requests

apikey = 'Your Baidu Apistore apikey'
url = 'http://apis.baidu.com/rtbasia/non_human_traffic_screening_vp/nht_query'
V={}
headers={'apikey': apikey}

def GetValue(ip):
    global V
    r=requests.get(url, params={'ip': ip}, headers=headers).json()
    state = r.get('code')
    ip    = r.get('ip')
    score = int(r.get('data').get('score'))
    if score < 50: V[ip] = score
    return {'state':state, 'ip':ip, 'score': score}

if __name__ == '__main__':
    import sys
    try:
        ipfile=sys.argv[1]
    except IndexError:
        ipfile='test.txt'
    with open(ipfile, 'r') as f:
        ips=f.readlines()
    for ip in ips:
        print GetValue(ip.strip())
    print "真人概率值低语50%的有以下IP:\n", V
