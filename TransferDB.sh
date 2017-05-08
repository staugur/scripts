#!/bin/bash
#
#将旧数据库表移动到新库中, 相当于重命名实例中的库
#当你执行脚本时，你不能有任何锁定的表或活动的事务。你同样也必须有对原初表的 ALTER 和 DROP 权限，以及对新表的 CREATE 和 INSERT 权限。
#
echo "请按照提示输入数据库信息,其中USER默认为root、HOST默认为localhost、PORT默认为3306."
read -p "USER:" USER
read -s -p "PASSWORD:" PASSWD
read -p "HOST:" HOST
read -p "PORT:" PORT
read -p "OLD_DB": OLD_DB
read -p "NEW_DB:" NEW_DB
if [ -z $USER ]; then
    USER=root
fi
if [ -z $HOST ]; then
    HOST=localhost
fi
if [ -z $HOST ]; then
    HOST=localhost
fi
if [ -z $PORT ]; then
    PORT=3306
fi
if [ -z $OLD_DB ] or [ -z $NEW_DB ]; then
    echo "OLD_DB旧库名 或 NEW_DB新库名 不能为空"; exit 1
fi
CONNECTION="mysql -u ${USER} -p${PASSWD} -h ${HOST} -P $PORT"
echo $CONNECTION


function create() {
    CREATE DATABASE IF NOT EXISTS $NEW_DB DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
}

function main() {
    dbs=$($CONNECTION -N -e "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE table_schema='${OLD_DB}';")
    create
    for name in $dbs; do
        $CONNECTION -e "RENAME TABLE ${OLD_DB}.$name to ${NEW_DB}.$name;"
    done
}


function delete() {
    $CONNECTION -e "DROP DATABASE ${OLD_DB};"
}

main

read -p "${OLD_DB}->${NEW_DB} 操作完成, 直接回车不删除旧库, 如需删除旧库 ${OLD_DB}, 请输入y: " isDel
if [ "$PidDel}" = "y" ]; then
    delete
fi
