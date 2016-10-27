#!/bin/bash
#要求有mailx包，开启了邮件服务
ci_dir=/tmp/baidu_ci
ci_urls=${ci_dir}/urls.txt
ci_r=${ci_dir}/ci_result.txt
[ -d $ci_dir ] || mkdir -p $ci_dir
[ -f $ci_urls ] && rm -f $ci_urls
check() {
   code=$(curl -I -s $url |head -1|awk -F "HTTP/1.1 " '{print $2}'|awk '{print $1}')
   if [ "$code" = "200" ];then
     echo $url >> $ci_urls
   fi
}
echo "http://www.saintic.com/" > $ci_urls
static_urls=(
    "http://www.saintic.com/coreweb/index.html"
    "http://www.saintic.com/sdpv1.0/index.html"
    "http://www.saintic.com/sdpv1.0/docker.html"
    "http://www.saintic.com/sdpv1.0/subversion.html"
    "http://www.saintic.com/sdpv1.0/vsftpd.html"
    "http://www.saintic.com/sdpv1.0/autodeploy.html"
    "http://www.saintic.com/blog"
)

for url in ${static_urls[@]}
do
   check
done 

for i in {1..20}
do
   url=http://www.saintic.com/blog/${i}.html
   check
done

curl -s -H 'Content-Type:text/plain' --data-binary @$ci_urls "http://data.zz.baidu.com/urls?site=www.saintic.com&token=YourToken" > $ci_r
#此处的curl就是你在百度站长平台看到的curl推送示例，其中@urls.txt改为@$ci_urls即可。

push_nums=$(jq .success ${ci_r})
fail_code=$(jq .error ${ci_r})
fail_msg=$(jq .message ${ci_r})

if [ $push_nums = "0" ];then
    echo "$(date +%Y-%m-%d,%H:%M:%S),推送异常，推送结果成功但条数为0！！！" | mailx -r "Baidu_ci@saintic.com" -s "百度实时推送:FAIL" staugur@vip.qq.com
    exit 1
fi

if [ "$push_nums" != "null" ];then
    mailx -r "Baidu_ci@saintic.com" -s "百度实时推送:SUCCESS" -c "staugur@saintic.com" staugur@vip.qq.com <<EOF
$(date +%Y-%m-%d,%H:%M:%S),成功推送${push_nums}条记录。
推送列表:
$(cat ${ci_urls})
EOF
else
    echo "$(date +%Y-%m-%d,%H:%M:%S),推送错误,错误代码:${fail_code},原因是:${fail_msg}." | mailx -r "Baidu_ci@saintic.com" -s "百度实时推送:FAIL" staugur@vip.qq.com
fi

