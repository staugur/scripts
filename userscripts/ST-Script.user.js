// ==UserScript==
// @name         ST-Script
// @namespace    https://www.saintic.com/
// @version      0.2
// @description  修改google背景图、去除页脚；CSDN自动阅读全文、关闭页脚登录注册框。
// @author       staugur
// @match        *://www.google.com/*
// @match        *://www.google.co.*/*
// @match        http*://blog.csdn.net/*/article/details/*
// @grant        none
// @icon         data:image/png;base64,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
// @github       https://github.com/staugur/scripts/blob/master/userscripts/ST-Script.user.js
// @supportURL   https://github.com/staugur/scripts/issues
// @license      MIT
// @date         2018-04-27
// @modified     2018-06-15
// ==/UserScript==

(function() {
    'use strict';
    //配置
    var conf = {
        google: {
            //此项设置是否开启修改google背景图功能
            enable: true,
            //此项设置是背景图地址，当上述项为true时有效
            bgUrl: "https://open.saintic.com/api/bingPic/",
            //此项设置隐藏google首页底部页脚
            hiddenFooter: true
        },
        csdn: {
            //此项设置自动展开全文
            auto_read_full: true,
            //此项设置关闭登录注册弹框
            auto_close_loginbox: true,
            //此项设置关闭左侧底部广告
            auto_remove_asidefooter: true
        }
    };
    //公共接口
    var api = {
        getDomain: function() {
            return document.domain;
        },
        getUrlRelativePath: function() {
            var url = document.location.toString();
            var arrUrl = url.split("//");
            var start = arrUrl[1].indexOf("/");
            var relUrl = arrUrl[1].substring(start); //stop省略，截取从start开始到结尾的所有字符
            if (relUrl.indexOf("?") != -1) {
                relUrl = relUrl.split("?")[0];
            }
            return relUrl;
        },
        getUrlQuery: function(key, acq) {
            /*
                获取URL中?之后的查询参数，不包含锚部分，比如url为http://passport.saintic.com/user/message/?status=1&Action=getCount
                若无查询的key，则返回整个查询参数对象，即返回{status: "1", Action: "getCount"}；
                若有查询的key，则返回对象值，返回值可以指定默认值acq：如key=status, 返回1；key=test返回acq
            */
            var str = location.search;
            var obj = {};
            if (str) {
                str = str.substring(1, str.length);
                // 以&分隔字符串，获得类似name=xiaoli这样的元素数组
                var arr = str.split("&");
                //var obj = new Object();
                // 将每一个数组元素以=分隔并赋给obj对象
                for (var i = 0; i < arr.length; i++) {
                    var tmp_arr = arr[i].split("=");
                    obj[decodeURIComponent(tmp_arr[0])] = decodeURIComponent(tmp_arr[1]);
                }
            }
            return key ? obj[key] || acq : obj;
        },
        isContains: function(str, substr) {
            /* 判断str中是否包含substr */
            return str.indexOf(substr) >= 0;
        },
        arrayContains: function(arr, obj) {
            var i = arr.length;
            while (i--) {
                if (arr[i] === obj) {
                    return true;
                }
            }
            return false;
        }
    };
    //给Google™ 搜索页设置个背景图片、隐藏页脚
    if (conf.google.enable === true) {
        if (api.isContains(api.getDomain(), "www.google.co") && api.arrayContains(["/", "/webhp"], api.getUrlRelativePath())) {
            //设置body背景颜色、图片、重复性、起始位置
            document.body.style.backgroundColor = "inherit";
            document.body.style.backgroundImage = "url('" + conf.google.bgUrl + "')";
            document.body.style.backgroundRepeat = "no-repeat";
            document.body.style.backgroundPosition = "50% 50%";
            //隐藏页脚
            if (conf.google.hiddenFooter === true) {
                document.getElementById('footer').style.display = 'none';
            }
        }
    }
    //CSDN文章详情页自动展开全文并去除阅读更多按钮
    if (conf.csdn.auto_read_full === true) {
        if (api.isContains(api.getDomain(), "blog.csdn.net")) {
            var btnReadmore = $("#btn-readmore");
            var articleBox = $("div.article_content");
            //先去除阅读更多部分的style(隐藏)
            articleBox.removeAttr("style");
            //再删除越多更多按钮
            btnReadmore.parent().remove();
        }
    }
    //CSDN文章详情页关闭底部登录注册框
    if (conf.csdn.auto_close_loginbox === true) {
        if (api.isContains(api.getDomain(), "blog.csdn.net")) {
            var pb = $('.pulllog-box');
            //隐藏显示
            pb[0].style.display = 'none';
        }
    }
    //CSDN删除asideFooter-侧栏底部，如联系我们
    if (conf.csdn.auto_remove_asidefooter === true) {
        if (api.isContains(api.getDomain(), "blog.csdn.net")) {
            //删除左侧栏底部
            $('#asideFooter').remove();
        }
    }
    //console.log("ST-Script is over");
})();