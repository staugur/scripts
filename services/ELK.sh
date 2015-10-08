#!/bin/bash
#Logststem=ElasticSearch+LogStash+Kibana+Redis
#server=elasticsearch+kibana[+redis],log_node=logstash
#Note:agent(input)=>redis(output,server,input)=>elasticsearch(filter)=>kibana(output)
e_ver="1.7.2"
l_ver="1.5.2"
k_ver="4.1.1"
soft_dir="/data/software"
app_dir="/data/app"
logstash_dir="${app_dir}/logstash"
elasticsearch_dir="${app_dir}/elasticsearch"
kibana_dir="${app_dir}/kibana"
logagent_dir="/usr/local/logstash"
[ -d $soft_dir ] || mkdir -p $soft_dir
[ -d $app_dir ] || mkdir -p $app_dir
yum -y install wget java-1.7.0-openjdk tar gzip curl
cd $soft_dir

download_all() {
  wget -c https://download.elasticsearch.org/logstash/logstash/logstash-${e_ver}.tar.gz
  wget -c https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${l_ver}.tar.gz
  wget -c https://download.elasticsearch.org/kibana/kibana/kibana-${k_ver}.tar.gz
}

redis() {
  curl https://saintic.top/redis.txt > redis.sh;sh redis.sh
}

logstash_agent() {
wget -c https://download.elasticsearch.org/logstash/logstash/logstash-${e_ver}.tar.gz
tar zxf logstash-${e_ver}.tar.gz -C ${logagent_dir};
[ "$?" = "0" ] || mv logstash-${e_ver} ${logagent_dir}
cd ${logagent_dir};mkdir conf logs;
cat > ${logagent_dir}/conf/shipper.conf <<'EOF'
input {
	file {
		type => "type_count"
		path => ["/var/log/messages", "/var/log/secure"]
		exclude => ["*.gz", "access.log"]
	}   
}
output {
	stdout {}
	redis {
		host => "redis_server_ip"
		port => 6379
		data_type => "list"
		key => "key_count"
	}   
}
EOF
${logagent_dir}/bin/logstash agent --verbose --config ${logagent_dir}/conf/shipper.conf --log ${logagent_dir}/logs/stdout.log &
}

#1.redis in server
if [ `netstat -anptl|grep redis|wc -l` -eq 0 ] && [ `which redis-server|wc -l` -eq 0 ];then
  redis
else
  echo "LogServer日志服务器需要redis，请启动服务或将命令加入PATH中。"
fi

#2.logstash in server
cd $soft_dir ; tar zxvf logstash-1.4.2.tar.gz -C ${logstash_dir}
cd ${logstash_dir};mkdir conf logs
cat > ${logstash_dir}/conf/central.conf<<EOF
input {
	redis {
		host => "127.0.0.1"
		port => 6379 
		type => "redis-input"
		data_type => "list"
		key => "key_count"
	}   
}
output {
	stdout {}
	elasticsearch {
		cluster => "elasticsearch"
		codec => "json"
		protocol => "http"
	}   
}
EOF

#3.elasticsearch
cd ${soft_dir};tar zxf elasticsearch-${l_ver}.tar.gz -C $elasticsearch_dir

#4.kibana
cd ${soft_dir};tar zxf kibana-${k_ver}.tar.gz -C $kibana_dir
#${logstash_dir}/bin/logstash agent --verbose --config ${logstash_dir}/conf/central.conf --log ${logstash_dir}/logs/stdout.log
${elasticsearch_dir}/bin/elasticsearch -d

