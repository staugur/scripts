# coding: utf8
# pip install pywin32

import win32api, win32con, win32gui, os, urllib


def set_wallpaper(img_api="https://open.saintic.com/api/bingPic/", img_path="D:\\BingWallpaper.jpg"):
    """ 自动更换windows壁纸，壁纸来源于Bing每日一图 """
    # 下载壁纸
    try:
        urllib.urlretrieve(img_api, filename=img_path)
    except Exception as e:
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