# _*_ coding: utf-8 _*_  
__author__ = 'Hondsam Xu <hondsam@hotmail.com>'  
import socket,struct  
  
''''' 
 转换为子网地址,并检验和输出正确的子网地址 
 192.168.2.1 -> 192.168.2.1/255.255.255.255 
 192.168.2.1/24 -> 192.168.2.0/255.255.255.0 
 192.168.2.1/255.255.255.0 -> 192.168.2.0/255.255.255.0 
 '''  
def format_subnet(subnet_input):  
    # 如果输入的ip，将掩码加上后输出  
    if subnet_input.find("/") == -1:  
        return subnet_input + "/255.255.255.255"  
  
    else:  
        # 如果输入的是短掩码，则转换为长掩码  
        subnet = subnet_input.split("/")  
        if len(subnet[1]) < 3:  
            mask_num = int(subnet[1])  
            last_mask_num = mask_num % 8  
            last_mask_str = ""  
            for i in range(last_mask_num):  
                last_mask_str += "1"  
            if len(last_mask_str) < 8:  
                for i in range(8-len(last_mask_str)):  
                    last_mask_str += "0"  
            last_mask_str = str(int(last_mask_str,2))  
            if mask_num / 8 == 0:  
                subnet = subnet[0] + "/" + last_mask_str +"0.0.0"  
            elif mask_num / 8 == 1:  
                subnet = subnet[0] + "/255." + last_mask_str +".0.0"  
            elif mask_num / 8 == 2 :  
                subnet = subnet[0] + "/255.255." + last_mask_str +".0"  
            elif mask_num / 8 == 3:  
                subnet = subnet[0] + "/255.255.255." + last_mask_str  
            elif mask_num / 8 == 4:  
                subnet = subnet[0] + "/255.255.255.255"  
            subnet_input = subnet  
  
        # 计算出正确的子网地址并输出  
        subnet_array = subnet_input.split("/")  
        subnet_true = socket.inet_ntoa( struct.pack("!I",struct.unpack("!I",socket.inet_aton(subnet_array[0]))[0] &    struct.unpack("!I",socket.inet_aton(subnet_array[1]))[0])) + "/" + subnet_array[1]  
        return subnet_true  
  
  
# 判断ip是否属于某个网段  
def ip_in_subnet(ip,subnet):  
    subnet = format_subnet(str(subnet))  
    subnet_array = subnet.split("/")  
    ip = format_subnet(ip + "/" + subnet_array[1])  
    return ip == subnet  
  
print ip_in_subnet("10.25.128.7", "10.0.0.0/255.0.0.0")
