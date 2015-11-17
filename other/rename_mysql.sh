#!/bin/bash
clear
#获取库名，从库中获取表，导出表，创建新库，将表导入新库中！
#read -p "USER:" USER
#read -s -p "PASSWORD:" PASSWD
#read -p "HOST:" HOST
#read -p "PORT:" PORT
#read -p "NEW_NAME_PRE:" HJ
CONNECTION="-u ${USER} -p${PASSWD} -h ${HOST} -P $PORT"

#Get data db
GetDB() {
mysql $CONNECTION -e "SHOW DATABASES;" > db
sed -i -e "/mysql/ d" -e "/information_schema/ d" -e "/Database/ d" -e "/performance_schema/ d" db
}

ObTables() {
	for i in `cat ${DB}_tables`
	do
		if [ "$i" != "" ]; then
			mysqldump $CONNECTION $DB $i > ${i}.sql
			if [ "$?" = "0" ]; then
				mysql $CONNECTION ${HJ}_${DB} < ${i}.sql
			fi
		fi
	done
}

#Get tables in someone db
RENAME() {
for DB in `cat db`
do 
	mkdir ${DB} ; cd ${DB}
    mysql $CONNECTION  -e "USE $DB;SHOW TABLES;" > ${DB}_tables
    sed -i '/Tables/ d' ${DB}_tables
	mysql $CONNECTION -e "CREATE DATABASE ${HJ}_${DB};"
    ObTables
    mysql $CONNECTION -e "DROP DATABASE ${DB};"
	cd ..
done
}

mkdir -p `date +%F`_db_rename ; cd `date +%F`_db_rename
GetDB && RENAME
