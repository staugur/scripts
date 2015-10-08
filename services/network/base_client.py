#coding:utf8
import socket
s=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host='127.0.0.1'
port=9999
s.connect((host,port))

print s.recv(4096)
try:
  while True:
    get_rq=raw_input('Enter Your String: ')
    data=str('sdi_')+get_rq
    if data == False or data == 'sdi_exit' or data == 'sdi_quit' or data == 'sdi_':
      break
    else:
      s.send(get_rq)
      print s.recv(4096)
finally: 
  s.send('exit')
  s.close()

