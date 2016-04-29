#!/bin/bash
if [ -z $1 ];then
  echo "Usage:$0 Nginx_access_log"
  exit 1
fi
function common {
  cat $1 |awk '{print $1}' | sort -nr | uniq -c | sort -nr | head
  cat $1 | awk '{print $1}' | sort | uniq -c | sort -nr | head 
  awk -F " " '{print $1}' $1 | sort | uniq -c | sort -nr | head
}
function json {
  cat $1 | jq .remote_addr | sort -nr | uniq -c | sort -nr | head
}

json $1

