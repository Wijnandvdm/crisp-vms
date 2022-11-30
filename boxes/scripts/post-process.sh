#!/bin/bash -x
echo "Post-processing for box: $2 with config:  $1"

ssh_config=$(vagrant --boxes-config=$1 ssh-config $2 | sed -e  "s/Host $2/Host $3/")
test_config=$(cat ~/.ssh/config | grep "Host $3" 2>&1 )
if [[ "${test_config}" == "" ]]; then
    $(echo "${ssh_config}" >> ~/.ssh/config)
fi

