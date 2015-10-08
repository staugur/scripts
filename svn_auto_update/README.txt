 
##使用说明
>1. `post-commit` 存放在SVN服务器，是SVN的钩子文件，存放在 `svn项目路径/hooks/post-commit`

>2. `svn.php` 存放在SVN服务器，供 `post-commit` 来执行，通过 `curl` 来触发模拟http协议访问Web测试服务器上的 `update.php`

>3. `update.php` 存放在Web测试服务器上，保证该脚本可以通过Web方式访问

>4. 测试通过将update.php放到线上，手动执行这个文件

##注意事项
使用过程可以会有很多的脚本执行权限问题，请往nginx和apache的属主和属组上修改
```shell
chown -R www:www xxx
```

转载自：http://mengkang.net/67.html
