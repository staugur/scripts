#coding:utf8
import socket,time,threading,sys
host='127.0.0.1'
port=9999

def tcplink(sock, addr):
  sock.send('Welcome!')
  while True:
    data=sock.recv(1024)
    time.sleep(1)
    if data == 'exit' or not data:
      break
    sock.send('Hello,%s!' % data)
  sock.close()
  print 'Connection from %s:%s closed.' % addr

try:
  s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
  s.bind((host,port))
  s.listen(5)
  print 'Waiting for connection...'
  while True:
    sock, addr=s.accept()
    t=threading.Thread(target=tcplink, args=(sock, addr))
    t.start()
except:
  print 'start error, server exit(1).'
  sys.exit(1)
