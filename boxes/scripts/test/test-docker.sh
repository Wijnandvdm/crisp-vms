#!/bin/bash
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail

# target machine's hostname
h_name=$1
# Script folder
sf_name=$2
source $sf_name/utils/utils-command.sh
sudo systemctl start docker && sudo systemctl start containerd
f_name="test_docker_${h_name}_$(date +"%Y%m%d").log"
set_log_dir $h_name

f_log "###   Testing Docker on host: ${h_name}    ###" "${f_name}" "${h_name}"
f_log "### Make sure docker deamon is running ###" "${f_name}" "${h_name}"
exec_cmd ${h_name} "sudo pgrep docker" 
f_log '### Starting Docker ###' "${f_name}" "${h_name}"
exec_cmd ${h_name} "sudo systemctl start docker" 
f_log "###   Try to run hello-world container on host: ${h_name}    ###" "${f_name}" "${h_name}"
response="$(exec_cmd $h_name "sudo docker run hello-world" | grep -oP "Hello from Docker!")"
result="test-docker:FAILED"
if [[ $response = "Hello from Docker!" ]]; then  
  result="test-docker:SUCCESS"
  f_log $result "${f_name}" "${h_name}"
fi
echo "${result}"