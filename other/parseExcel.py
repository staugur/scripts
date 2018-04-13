# coding: utf8
# pip install openpyxl

import sys
from openpyxl import load_workbook
reload(sys)
sys.setdefaultencoding('utf-8')


def parse(f, query):
    """解析xlsx文件，根据search搜索title字样数据"""
    wb = load_workbook(f)
    bs = wb.active
    #data = list(bs.values)
    data = bs.values
    need = [ i for i in data if i[1] and u"%s" %query in "%s" %i[1] ]
    return need

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", help="xlsx格式的文件")
    parser.add_argument("-q", "--query", help="搜索标题字样")
    parser.add_argument("-a", "--action", help="搜索后动作，show|save，分别是查看|保存，默认show", default="show")
    parser.add_argument("-s", "--save", help="action=save时要保存的文件名，默认tmp.txt", default="tmp.txt")
    args = parser.parse_args()
    f = args.file
    q = args.query
    a = args.action
    s = args.save
    if f and q:
        data = parse(f, q)
        cstr = lambda x: "%s" %x
        if a == "show":
            for i in data:
                print " ".join(map(cstr, i))
        elif a == "save":
            with open(s, "w") as f:
                for i in data:
                    f.write(" ".join(map(cstr, i)) + "\r\n")
    else:
        parser.print_help()
