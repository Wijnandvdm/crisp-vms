#!/bin/bash

# load configuration
source configurations/ubuntu.sh

# prompt user for information
echo "Please enter a name for the new virtual machine:"
read vm_name

echo "Please enter a username for the new virtual machine:"
read username

echo "Please enter a password for the new virtual machine:"
read -s password

path_to_vdi="vms/${vm_name}.vdi"
path_to_os_image="images/${os_image_name}"

# check if vm exists, if not, create vm
echo "looking for vm..."
vm_exists=$(VBoxManage list vms | grep ${vm_name})
if [ -z "${vm_exists}" ]; then
    echo "vm not found, creating vm..."
    # create and register machine
    VBoxManage createvm --name ${vm_name} --ostype ${os_type} --register
else
    echo "vm found, continuing..."
fi

# check if storage medium exists, if not, create one
echo "looking for storage medium..."
if [ ! -f ${path_to_vdi} ]; then
    echo "storage medium not found, creating storage medium..."
    # setup vm storage medium
    VBoxManage createmedium \
    --filename ${path_to_vdi} \
    --size ${disk_size}
else
    echo "storage medium found, continuing..."
fi

# Add and Attach SATA and IDE Storage Controllers
VBoxManage storagectl ${vm_name} --name SATA --add SATA --controller IntelAhci --portcount 1
VBoxManage storageattach ${vm_name} \
--storagectl SATA --port 0 --device 0 --type hdd \
--medium ${path_to_vdi}

VBoxManage storagectl ${vm_name} --name IDE --add ide --controller PIIX4
VBoxManage storageattach ${vm_name} \
--storagectl IDE --port 0 --device 0 --type dvddrive \
--medium ${path_to_os_image}

# Set the VM RAM and Virtual graphics card RAM size
VBoxManage modifyvm ${vm_name} --memory ${ram} --vram ${vram} --graphicscontroller vmsvga

# Enable IO APIC because guest OS is 64 bit 
VBoxManage modifyvm ${vm_name} --ioapic on

# Define the boot order for the virtual machine
VBoxManage modifyvm ${vm_name} --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Define the number of virtual CPUs for the VM
VBoxManage modifyvm ${vm_name} --cpus ${cpus}

# Define the Networking settings for the VM
VBoxManage modifyvm ${vm_name} --nic1 nat

# Enable bidirectional clipboard and drag and drop, only possible when Guest Additionals are installed
VBoxManage modifyvm ${vm_name} --clipboard bidirectional --draganddrop bidirectional

VBoxManage unattended install ${vm_name} \
--iso=${path_to_os_image} \
--user=${username} \
--full-user-name=${username} \
--password=${password} \
--time-zone=${time_zone} \
--language=${language} \
--install-additions \
--post-install-command="su - && usermod -a -G sudo ${username}"
# --hostname="${vm_name}.${vm_name}" \

VBoxHeadless --startvm ${vm_name}