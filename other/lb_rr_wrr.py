# coding:utf8
# https://www.cnblogs.com/xybaby/p/7867735.html
# 多进程下，需要修改了，比如改为rr算法中的cur，从redis读取，+1后写入redis

# 轮询算法（round-robin）

SERVER_LIST = [
    '10.246.10.1',
    '10.246.10.2',
    '10.246.10.3',
]


def round_robin(server_lst, cur=[0]):
    # cur此时要求是一个可变参数
    length = len(server_lst)
    ret = server_lst[cur[0] % length]
    cur[0] = (cur[0] + 1) % length
    return ret


# 加权轮询算法（weight round-robin）
WEIGHT_SERVER_LIST = {
    '10.246.10.1': 1,
    '10.246.10.2': 3,
    '10.246.10.3': 2,
}
WEIGHT_SERVER_LIST = [
    dict(ip='10.246.10.1', weight=1),
    dict(ip='10.246.10.2', weight=2),
    dict(ip='10.246.10.3', weight=3),
]

def weight_round_robin(servers, cur=[0]):
    # 根据权重更新到list中，权重大重复元素多
    server_lst = []
    # 针对dict
    # for k, v in servers.iteritems():
    #    server_lst.extend([k] * v)
    # 针对list
    for i in servers:
        if i and isinstance(i, dict):
            server_lst.extend([i] * (int(i.get("weight", 1)) or 1))
    # 再根据轮询算法从list中取数据
    length = len(server_lst)
    ret = server_lst[cur[0] % length]
    cur[0] = (cur[0] + 1) % length
    return ret


# 哈希法（ip-hash）
def hash_choose(request_info, server_lst):
    hashed_request_info = hash(request_info)
    return server_lst[hashed_request_info % len(server_lst)]
