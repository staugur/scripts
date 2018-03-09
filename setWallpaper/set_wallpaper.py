# -*- coding: utf-8 -*-
"""
    set_wallpaper
    ~~~~~~~~~~~~~~

    Win10自动更换壁纸，壁纸来源于Bing每日一图

    0. 默认的set_wallpaper.exe需要有D盘存在并有权限写入，否则请按照以下步骤重新打包

    1. 下载代码并安装依赖包
        pip install pywin32

    2. 打包 
        2.1 pip install PyInstaller
        2.2 打开cmd(或powershell)，进入脚本所在目录，执行：
            pyinstaller.exe -F set_wallpaper.py -i win.ico -w

    3. set_wallpaper函数参数
        img_api: 图片来源地址(默认给出的可以获取每日Bing美图)
        img_path: 图片存放在Windows中的绝对路径

    :copyright: (c) 2018 by staugur.
    :license: MIT, see LICENSE for more details.
"""

import os
import urllib
import win32api
import win32con
import win32gui


def set_wallpaper(img_api="https://open.saintic.com/api/bingPic/", img_path="D:\\BingWallpaper.jpg"):
    # 下载壁纸
    try:
        urllib.urlretrieve(img_api, filename=img_path)
    except:
        raise
    else:
        # 打开指定注册表路径
        reg_key = win32api.RegOpenKeyEx(win32con.HKEY_CURRENT_USER, "Control Panel\\Desktop", 0, win32con.KEY_SET_VALUE)
        # 最后的参数:2拉伸,0居中,6适应,10填充,0平铺
        win32api.RegSetValueEx(reg_key, "WallpaperStyle", 0, win32con.REG_SZ, "2")
        # 最后的参数:1表示平铺,拉伸居中等都是0
        win32api.RegSetValueEx(reg_key, "TileWallpaper", 0, win32con.REG_SZ, "0")
        # 刷新桌面
        win32gui.SystemParametersInfo(win32con.SPI_SETDESKWALLPAPER, img_path, win32con.SPIF_SENDWININICHANGE)


if __name__ == "__main__":
    set_wallpaper()
