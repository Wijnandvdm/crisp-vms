#!/bin/bash
MACHINENAME=scorched-earth

#Source of inspiration:
# https://andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/

# Download linux.iso
if [ ! -f ./images/linux.iso ]; then
    echo "image not found, downloading image..."
    curl -o images/linux.iso https://releases.ubuntu.com/20.04.5/ubuntu-20.04.5-live-server-amd64.iso
else
    echo "image already exists, continuing..."
fi

# GLOBAL PARAMETERS
PRESWORKDIR=`pwd`/vms/${MACHINENAME}

#Create VM
VBoxManage createvm --name ${MACHINENAME} --ostype "Ubuntu_64" --register --basefolder `pwd`/vms

# VBoxManage modifyvm ${MACHINENAME} --ioapic on

#Supply VM with 4GB working memory and 256MB
VBoxManage modifyvm ${MACHINENAME} --memory 4096 --vram 256
#Set Network
VBoxManage modifyvm ${MACHINENAME} --nic1 nat
#Set processors
VBoxManage modifyvm ${MACHINENAME} --cpus 4

#Create Disk and connect Linux Iso
VBoxManage createmedium --filename ${PRESWORKDIR}/${MACHINENAME}_DISK.vmdk --size 131072 --format VMDK
# VBoxManage storagectl ${MACHINENAME} --name "SATA Controller" --add ide --controller IntelAhci
# VBoxManage storageattach ${MACHINENAME} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  ${PRESWORKDIR}/${MACHINENAME}_DISK.vmdk
VBoxManage storagectl ${MACHINENAME} --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach ${MACHINENAME} --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/images/linux.iso
VBoxManage modifyvm ${MACHINENAME} --boot1 disk --boot2 dvd --boot3 none --boot4 none

# #Enable RDP
# VBoxManage modifyvm ${MACHINENAME} --vrde on
# VBoxManage modifyvm ${MACHINENAME} --vrdemulticon on --vrdeport 10001

#Start the VM
# VBoxHeadless --startvm ${MACHINENAME}