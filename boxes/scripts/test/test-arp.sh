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

f_name="test_osi_layer2_${h_name}_$(date +"%Y%m%d").log"

f_log "###   ARP information of ${h_name}    ###"
f_log "###   OSI Layer 2 demo (data link)    ###" 
f_log "###   Show ARP table of $h_name       ###"
exec_cmd $h_name "sudo arp -v" 

f_log "###   Flush ARP table of $h_name      ###"
exec_cmd $h_name "sudo ip -s -s neigh flush all"

f_log "###   Log result of flush             ###"
exec_cmd $h_name "sudo arp -v"

f_log "###   Add ARP entry by pinging a host ###"
validate_ping $h_name $ip_addr 0

f_log "###   Check if entry was added to ARP ###"
exec_cmd $h_name "sudo ip neigh show $ip_addr"

f_log "###   Set invalid hw address          ###"
exec_cmd $h_name "sudo ip neigh replace $ip_addr lladdr 1:2:3:4:5:6 dev eth1"

f_log "###   Verify faulty entry with ping   ###"
validate_ping $h_name $ip_addr 100

if [[ ! "$HOSTNAME" == "$h_name" ]]; then
  # from a remote machine we query for the correct MAC
  f_log "###   Get the correct MAC address     ###"
  f_log "###   for $ip_addr on eth1            ###"
  mac=$(exec_cmd $test_h_name "sudo ip -br link | grep eth1" | awk '{print $5 }')
  f_log "###   Set correct mac address in ARP  ###"
  f_log "###   table of $h_name                ###" 
  exec_cmd $h_name "sudo ip neigh replace $ip_addr lladdr ${mac} dev eth1"
else
  # We run in the box where we just set a faulty address
  # Remove the entry and try to fix it with a ping
  f_log "###  Remove invalid entry from ARP table of $h_name                ###" 
  exec_cmd $h_name "sudo ip neigh del $ip_addr dev eth1"
fi
f_log "###   Check if resolution is fine     ###"
validate_ping $h_name $ip_addr 0