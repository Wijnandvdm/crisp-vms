#!/bin/bash

echo "Executing post-install-script.sh..."

execute_vbox_cli_command(){
    local vm_name=$1
    local username=$2
    local password=$3
    local command_to_be_executed_on_vm=$4
    VBoxManage guestcontrol "${vm_name}" run --exe 'usr/bin/bash' --username "${username}" --password "${password}" --wait-stdout --wait-stderr -- '/bin/bash' '-c' "${command_to_be_executed_on_vm}" > /dev/null 2>&1
}

vm_name=$1
username=$2
password=$3
configuration=$4
source "${configuration}"

counter=0

echo "Polling VM by executing the command of adding supplied user to sudoer list until VM is up and running."
echo "When this is the case, command will no longer fail and script will proceed."
# Loop until the command succeeds
until execute_vbox_cli_command "${vm_name}" "root" "${password}" "echo '${username}     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"; do
    echo "Command failed, retrying in 60 seconds..."
    sleep 60
    counter=$((counter + 60))
    echo "Counter is currently at ${counter} seconds"
    if [ $counter -ge 10000 ]; then
        echo "Counter reached 10000 seconds, breaking out of the loop."
        break
    fi
done

echo "Command succeeded, performing other actions..."
for command in "${array_of_commands[@]}"; do
    echo "Executing command: ${command}"
    execute_vbox_cli_command "${vm_name}" "${username}" "${password}" "${command}"
done
echo "Your VM ${vm_name} is ready for use!"