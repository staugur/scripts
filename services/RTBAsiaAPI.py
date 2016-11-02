#!/usr/bin/python -O
# -*- coding: utf-8 -*-

import requests

apikey = 'e25c4d6a8a28349bb7a6cb076057c609'
url = 'http://apis.baidu.com/rtbasia/non_human_traffic_screening_vp/nht_query'
V={}
G={}
headers={'apikey': apikey}

def GetValue(ip):
    global V
    r=requests.get(url, params={'ip': ip}, headers=headers).json()
    state = r.get('code')
    ip    = r.get('ip')
    score = int(r.get('data').get('score'))
    if score < 50:
        V[ip] = score
    else:
        G[ip] = score
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
    print "真人概率值低于50%的有以下IP:\n", V
    print "真人概率值高于50%的有以下IP:\n", G
