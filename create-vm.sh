#!/bin/bash

echo "Please enter a name for the new virtual machine:"
read vm_name

echo "Please enter a username for the new virtual machine:"
read username

echo "Please enter a password for the new virtual machine:"
read -s password

# Get the current directory of the script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

select_file_in_directory(){
    local directory=$1
    local type=$2

    file_array=()
    # Populate the array with filenames
    while IFS= read -r -d $'\0' file; do
        file_array+=("$file")
    done < <(find "${directory}" -maxdepth 1 -type f -print0)

    for file in "${file_array[@]}"; do
        read -p "Do you want to use the ${type}: $file? (y/n): " choice

        if [ "$choice" == "y" ]; then
            selected_file="$file"
            echo ${selected_file}
            break  # Exit the loop if the user selects 'y'
        fi
    done
}

configuration=$(select_file_in_directory "${script_dir}/configurations" "configuration")
source "${configuration}"

path_to_vdi="vms/${vm_name}.vdi"

echo "Looking for VM..."
vm_exists=$(VBoxManage list vms | grep ${vm_name})
if [ -z "${vm_exists}" ]; then
    echo "VM not found, creating and registering VM..."
    VBoxManage createvm --name ${vm_name} --ostype ${os_type} --register
else
    echo "VM found, continuing..."
fi

echo "looking for storage medium..."
if [ ! -f ${path_to_vdi} ]; then
    echo "storage medium not found, creating storage medium..."
    VBoxManage createmedium \
    --filename ${path_to_vdi} \
    --size ${disk_size}
else
    echo "storage medium found, continuing..."
fi

if [ ! -d "${script_dir}/images" ]; then
    echo "Error: The 'images' directory does not exist. Creating one now..."
    mkdir images
    echo "Please copy your downloaded iso image to the images directory and run the script again"
    exit 1
fi

os_image_name=$(select_file_in_directory "${script_dir}/images" "image")
# Add and Attach SATA and IDE Storage Controllers
VBoxManage storagectl ${vm_name} --name SATA --add SATA --controller IntelAhci --portcount 1
VBoxManage storageattach ${vm_name} --storagectl SATA --port 0 --device 0 --type hdd --medium ${path_to_vdi}
VBoxManage storagectl ${vm_name} --name IDE --add ide --controller PIIX4
VBoxManage storageattach ${vm_name} --storagectl IDE --port 0 --device 0 --type dvddrive --medium ${os_image_name}

# Set the VM RAM and Virtual graphics card RAM size
# Enable IO APIC because guest OS is 64 bit
# Define the boot order for the virtual machine
# Define the number of virtual CPUs for the VM
# Define the Networking settings for the VM
# Enable bidirectional clipboard and drag and drop, only possible when Guest Additionals are installed
VBoxManage modifyvm ${vm_name} --memory ${ram} --vram ${vram} --graphicscontroller vmsvga \
--ioapic on \
--boot1 dvd --boot2 disk --boot3 none --boot4 none \
--cpus ${cpus} \
--nic1 nat \
--clipboard bidirectional --draganddrop bidirectional

VBoxManage unattended install ${vm_name} \
--iso=${os_image_name} \
--user=${username} \
--full-user-name=${username} \
--password=${password} \
--time-zone=${time_zone} \
--language=${language} \
--install-additions > /dev/null 2>&1

VBoxManage startvm ${vm_name} --type headless > /dev/null 2>&1

bash post-install-script.sh ${vm_name} ${username} ${password} ${configuration}