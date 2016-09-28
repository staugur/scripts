#!/usr/bin/python

import os
import sys
import commands

#BASEDIR=os.path.dirname(os.path.abspath(__file__))

def init(filename=None):
    if filename:
        cmd1="dos2unix %s"%filename
        cmd2="sed -i -e '/^#/d' -e '/^$/d' %s"%filename
    else:
        cmd1="dos2unix *.properties"
        cmd2="sed -i -e '/^#/d' -e '/^$/d' *.properties"
    commands.getoutput(cmd1)
    commands.getoutput(cmd2)

def parse(files=None):
    d={}
    if files:
        files=(files,)
    else:
        files=os.listdir('.')
    for f in files:
        if f == 'done.py':continue
        with open(f, 'r') as _f:
            v=[ _ for _ in _f.readlines() if _ ]
            #print v
        d[f]=v
    return d

def main(d):
    for k,v in d.iteritems():
        print "*" * 50, k, "*" * 50
        i=0
        for _ in v:
            if _.count('#') == 0:
                line=_.strip()
                #print line
                try:
                    key,value=line.split('=')
                except Exception, e:
                    if line.split('=')[0] == 'http.p3p.policy.header':
                        key,value='http.p3p.policy.header',line.split('http.p3p.policy.header=')[-1]
                    else:
                        raise
                cmd="sed -i 's#%s=.*#%s=%s#g' %s" %(key, key, value, k)
                print cmd
                commands.getoutput(cmd)
                i+=1
        print i,len(v),'\n'

if __name__ == "__main__":
    try:
        filename=sys.argv[1]
    except:
        filename=None
    init()
    main(parse(filename))
