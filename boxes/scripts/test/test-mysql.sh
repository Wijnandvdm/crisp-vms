#!/bin/bash
# test if mysql is up and provisioned database is loaded

# Script folder
sf_name=$3
source $sf_name/utils/utils-command.sh
# target machine's hostname
h_name=$1

sql_database=$2
sql_user=$4
sql_password=$5
sql_host=$6
sql_port=$7

f_name="test_mysql_${h_name}_$(date +"%Y%m%d").log"

f_log "###   Testing mysql  on  ${h_name}    ###"

echo "Testing MySQL...."

test=$(mysql -u${sql_user} -p${sql_password} -h${sql_host} -P${sql_port} -se "use ${sql_database}; select 'ok';")
echo "${test}"
if [[ "${test}" == "ok" ]]; then
  echo "..... Test OK"
else
  echo "..... TEST FAILED"
fi