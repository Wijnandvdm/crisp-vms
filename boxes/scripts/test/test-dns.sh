#!/bin/bash 
echo $@

source /vagrant/scripts/utils/utils-dns-client.sh
echo "### RUNNING TESTS"
echo "### Testing nameserver resolution for $1.$3....." 

if [[ $4 == 'NS' ]]; then
  test_dns tmp_var $3 $2 $1.$3. $4
else
  test_dns tmp_var $1 $2 $3 $4
fi

if [[ $tmp_var == true ]]; then
  echo " ..... TEST OK."
else 
  echo " ..... TEST FAILED."
fi


