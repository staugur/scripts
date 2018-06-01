// ==UserScript==
// @name         屏蔽畅言广告
// @namespace    https://www.saintic.com/
// @version      0.1
// @description  屏蔽畅言评论框下广告
// @author       staugur
// @match        http*://*/*
// @grant        GM_addStyle
// @license      MIT
// @date         2018-06-01
// @modified     none
// @github       https://github.com/staugur/scripts
// @supportURL   https://github.com/staugur/scripts/issues
// ==/UserScript==

(function() {
    'use strict';
    /*
        公共接口
    */
    //判断页面中id是否存在
    function hasId(id) {
        //有此id返回true，否则返回false
        var element = document.getElementById(id);
        if (element) {
            return true
        } else {
            return false
        }
    }
    /*
        主要代码
    */
    console.log(hasId('feedAv'));
    if (hasId("feedAv") === true) {
        GM_addStyle('#feedAv{ margin-top: -250px!important;transform: scale(0);}');
        setTimeout(function() {
            document.getElementById("feedAv").style.display = "none";
            document.getElementById('feedAv').id = "feedAvBak";
        }, 2000);
    }
})();