$str任意数字，判断是否是正整数
  #判断时间格式
  if [[ "$str" =~ ^[0-9]+$ ]]; then
    echo "符合"
  else
    echo "不符合"
  fi


$str为邮箱地址，判断是否为邮箱格式
  #判断邮箱格式
  if [[ `echo $str | sed -r '/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-])+/!d'` == "" ]]; then
    echo "邮箱格式不正确！"
  fi


shell数组，及判断某个元素是否属于数组。
比如：services=("redis" "mongodb" "mysql" "memcached" "nginx")
然后判断httpd是否属于services数组，
  if echo "${services[@]}" | grep -w httpd &> /dev/null ;then
    echo "属于"
  else
    echo "不属于"
  fi

​
 