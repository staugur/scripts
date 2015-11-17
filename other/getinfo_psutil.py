#!/usr/bin/env python
#coding:utf8
#get system info from psutil
#required:psutil
try:
  import sys,psutil,platform,commands,json,socket,os
except ImportError as msg:
  print "Import Error, because %s" % msg
  sys.exit(1)

class SysInfo():
  '''Get System Info for linux'''
  sys_ip=socket.gethostbyname(socket.gethostname())
  
  client_ip=os.environ['SSH_CONNECTION'].split()[0]
  sys_version=platform.linux_distribution()
  sys_fqdn=platform.uname()[1]   #hostname,eg:localhost.localdomain
  sys_kernel=platform.uname()[2] #kernel version
  sys_arch=platform.uname()[4]   #eg:x86_64 amd64 win32
  
  def hostname(self):
    return json.dumps({"Hostname": self.sys_fqdn})

  def ip(self):
    return json.dumps({"ServerIP": self.sys_ip, 'SSH_Client_IP': self.client_ip})

  def Kernel(self):
    return json.dumps({"Kernel": self.sys_kernel})

  def Arch(self):
    return json.dumps({"Arch": self.sys_arch})

  def Version(self):
    return json.dumps({"SysVersion": self.sys_version})

  def CPU(self):
    try:
      cpu_label=str(commands.getoutput('grep "model name" /proc/cpuinfo | awk -F ": " \'{print $2}\' | head -1'))
      cpu_cache=str(commands.getoutput('grep "cache size" /proc/cpuinfo|uniq|awk \'{print $4,$5}\''))
    except:
      cpu_label,cpu_cache='',''
    cpu_time=psutil.cpu_times()
    cpu_logical_nums=psutil.cpu_count()
    cpu_physical_nums=psutil.cpu_count(logical=False)
    return json.dumps({"Label": str(cpu_label), "Logical": int(cpu_logical_nums), "Cache_size": str(cpu_cache)})

  def MEM(self):
    mem=psutil.virtual_memory()
    total=mem.total
    free=mem.free
    buffers=mem.buffers
    cached=mem.cached
    UsedPerc=100 * int(total - free - cached - buffers) / int(total)
    mem_total=str(total / 1024 / 1024) + 'M'
    mem_free=str(free / 1024 / 1024) + 'M'
    memused=str(UsedPerc)+'%'
    return json.dumps({"Total": mem_total, "Free": mem_free, "Memory_UsageRate": memused})

  def DISK(self):
    ps=0
    pt=[]
    while ps < len(psutil.disk_partitions()):
      for i in range(3):
        pt.append(psutil.disk_partitions()[ps][i])
      pt.append(str(psutil.disk_usage(psutil.disk_partitions()[ps][1])[-1])+'%')
      ps+=1
    return json.dumps({"Partitions": len(psutil.disk_partitions()), "DiskInfo": pt})

  def NETWORK(self):
    net_io=psutil.net_io_counters(pernic=False)[0:4]
    return json.dumps({"NetworkFlow": str(net_io)})

  def OTHER(self):
    login_users=len(psutil.users())
    pid_nums=len(psutil.pids())
    return json.dumps({"LoginUserNums": int(login_users), "PidNums": int(pid_nums)})

if __name__ == '__main__':
  info=SysInfo()
  print info.hostname()
  print info.ip()
  print info.Version()
  print info.Kernel()
  print info.Arch()
  print info.CPU()
  print info.MEM()
  print info.DISK()
  #print info.NETWORK()
  print info.OTHER()
