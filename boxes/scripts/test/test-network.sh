#!/bin/bash

# Script folder
sf_name=$3
source $sf_name/utils/utils-command.sh
# target machine's hostname
h_name=$1
# ip address
ip_addr=$2
# Test entry hostname
test_h_name=$4

f_name="test_osi_layer3_${h_name}_$(date +"%Y%m%d").log"

f_log "###   Network information of ${h_name}    ###"
f_log "###   Ip route    ###"
default_gw=$(exec_cmd $h_name "sudo ip route show default" | awk '/default/ { print $5 }')
echo $default_gw