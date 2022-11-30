#!/bin/bash 
### Examples:
### Test interface from remote machine
### $ /bin/bash scripts/test/test-interfaces.sh ns1 eth1 ./scripts
### Run all provided tests on supplied interfaces through vagrant provisioner for all boxes
### $ vagrant provision
### Run all provided tests on supplied interfaces through vagrant provisioner on specific box
### $ vagrant provision ns1

# target machine's hostname
h_name=$1
# Interface name
if_name=$2
# Script folder
sf_name=$3

source $sf_name/utils/utils-command.sh

set_log_dir $h_name

f1_out="${logdir}/test_osi_layer1_${h_name}_${if_name}.log"
echo "logging to ${f1_out}"
echo "### Interface information of ${h_name} ####" | tee "$f1_out"
# Test if script is ran local or remote
if [[ ! "$HOSTNAME" == "$h_name" ]]; then 
  # assume remote; execute over ssh
  echo "### Interface ${if_name} status" | tee -a "$f1_out"
  echo "### Testing interface ${if_name} of $h_name ....."
  ssh $h_name "sudo ip link"  | tee -a "$f1_out"
  if_state=$(ssh $h_name "sudo cat /sys/class/net/${if_name}/operstate" 2>&1)
  ssh $h_name "sudo ethtool ${if_name} | grep -i 'Link det'"  | tee -a "$f1_out"
else
  # assume local
  sudo ip link | tee -a "$f1_out"
  sudo ethtool $if_name | grep -i 'Link det'
  if_state=$(sudo cat /sys/class/net/$if_name/operstate)
fi

if [[ $if_state == "up" ]]; then
  echo "Interface ${if_name} is ${if_state} ..... TEST OK"  | tee -a "$f1_out"
else
  echo "Interface ${if_name} is down ..... TEST FAILED"   | tee -a "$f1_out"
fi


