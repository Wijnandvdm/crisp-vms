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

counter=0

# Loop until the command succeeds
until execute_vbox_cli_command "${vm_name}" "root" "${password}" "echo '${username}     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"; do
# until VBoxManage guestcontrol ${vm_name} run --exe "usr/bin/bash" --username "root" --password ${password} --wait-stdout --wait-stderr -- "/bin/bash" "-c" "echo '${username}     ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" > /dev/null 2>&1; do
    echo "Command failed, retrying in 60 seconds..."
    sleep 60
    counter=$((counter + 60))
    echo "counter is currently at ${counter} seconds"
done

# Other actions to perform after the command succeeds
echo "Command succeeded, performing other actions..."

array_of_commands=(
    "mkdir ~/repos"
    "sudo snap install code --classic"
    "sudo apt-get install -y git"
    )

for command in "${array_of_commands[@]}"; do
    echo "Executing command: ${command}"
    execute_vbox_cli_command "${vm_name}" "${username}" "${password}" "${command}"
done