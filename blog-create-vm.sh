#!/bin/bash

# source: https://kifarunix.com/automate-virtual-machine-installation-on-virtualbox/

VM_NAME="jumbo-vm"

PATH_TO_VDI="vms/${VM_NAME}.vdi"
PATH_TO_IMAGE="images/ubuntu-22.04.2-desktop-amd64.iso"

# check if vm exists, if not, create vm
echo "looking for vm..."
VM_EXISTS=$(VBoxManage list vms | grep ${VM_NAME})
if [ -z "${VM_EXISTS}" ]; then
    echo "vm not found, creating vm..."
    # create and register machine
    VBoxManage createvm --name ${VM_NAME} --ostype Ubuntu_64 --register
else
    echo "vm found, continuing..."
fi

# check if storage medium exists, if not, create one
echo "looking for storage medium..."
if [ ! -f ${PATH_TO_VDI} ]; then
    echo "storage medium not found, creating storage medium..."
    # setup vm storage medium
    VBoxManage createmedium \
    --filename ${PATH_TO_VDI} \
    --size 10240
else
    echo "storage medium found, continuing..."
fi

# Add and Attach SATA and IDE Storage Controllers
VBoxManage storagectl ${VM_NAME} --name SATA --add SATA --controller IntelAhci

VBoxManage storageattach ${VM_NAME} \
--storagectl SATA --port 0 --device 0 --type hdd \
--medium ${PATH_TO_VDI}

VBoxManage storagectl ${VM_NAME} --name IDE --add ide
VBoxManage storageattach ${VM_NAME} \
--storagectl IDE --port 0 --device 0 --type dvddrive \
--medium ${PATH_TO_IMAGE}

# Set the VM RAM and Virtual graphics card RAM size
VBoxManage modifyvm ${VM_NAME} --memory 4096 --vram 16

# Enable IO APIC
VBoxManage modifyvm ${VM_NAME} --ioapic on

# Define the boot order for the virtual machine
VBoxManage modifyvm ${VM_NAME} --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Define the number of virtual CPUs for the VM
VBoxManage modifyvm ${VM_NAME} --cpus 2

# Define the Networking settings for the VM
VBoxManage modifyvm ${VM_NAME} --nic1 nat

VBoxManage unattended install ${VM_NAME} \
--iso=${PATH_TO_IMAGE} \
--user=username --password=password \
--time-zone=America/New_York \
--language=en_US \
--install-additions \


# --post-install-command="sudo apt-get update && sudo apt-get upgrade -y"
