// ==UserScript==
// @name         ST-Script
// @namespace    https://www.saintic.com/
// @version      0.2
// @description  修改google背景图；CSDN自动阅读全文。
// @author       staugur
// @match        *://www.google.com/*
// @match        *://www.google.co.*/*
// @match        http://blog.csdn.net/*/article/details/*
// @match        https://blog.csdn.net/*/article/details/*
// @grant        none
// @installURL   https://github.com/staugur/scripts
// @supportURL   https://passport.saintic.com/feedback.html
// @license      MIT
// @date         2018-04-27
// @modified     2018-04-28
// ==/UserScript==

(function() {
    'use strict';
    //配置
    var conf = {
        google: {
            bgUrl: "https://img.saintic.com/ImgBg/bg.jpg",
            hiddenFooter: true
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
    if (api.isContains(api.getDomain(), "www.google.co") && api.arrayContains(["/", "/webhp"], api.getUrlRelativePath())) {
        //设置body背景颜色、图片、重复性、起始位置
        document.body.style.backgroundColor = "inherit";
        document.body.style.backgroundImage = "url('" + bgUrl + "')";
        document.body.style.backgroundRepeat = "no-repeat";
        document.body.style.backgroundPosition = "50% 50%";
        //隐藏页脚
        document.getElementById('footer').style.display = 'none';
    }
    //CSDN文章详情页自动展开全文并去除阅读更多按钮
    if (api.isContains(api.getDomain(), "blog.csdn.net")) {
        var btnReadmore = $("#btn-readmore");
        var articleBox = $("div.article_content");
        //先去除阅读更多部分的style(隐藏)
        articleBox.removeAttr("style");
        //再删除越多更多按钮
        btnReadmore.parent().remove();
    }
    //console.log("ST-Script is over");
})();