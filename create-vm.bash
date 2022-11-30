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

## SYSTEM
#Supply VM with 4GB working memory, set processors and set boot order
VBoxManage modifyvm ${MACHINENAME} --memory 4096 --cpus 4 --boot1 disk --boot2 dvd --boot3 none

## DISPLAY
#Supply VM with 256 video memory
VBoxManage modifyvm ${MACHINENAME} --vram 256

## STORAGE
# #Create Disk and connect Linux Iso
# VBoxManage createmedium --filename ${PRESWORKDIR}/${MACHINENAME}_DISK.vmdk --size 131072 --format VMDK
# VBoxManage storagectl ${MACHINENAME} --name "SATA Controller" --add sata --controller IntelAhci
# VBoxManage storageattach ${MACHINENAME} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  ${PRESWORKDIR}/${MACHINENAME}_DISK.vmdk
# # VBoxManage storagectl ${MACHINENAME} --name "IDE Controller" --add ide --controller PIIX4
# # VBoxManage storageattach ${MACHINENAME} --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/images/linux.iso


## LEGACY
VBoxManage createhd --filename ${PRESWORKDIR}/$MACHINENAME_DISK.vdi --size 131072 --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  ${PRESWORKDIR}/$MACHINENAME_DISK.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/images/linux.iso

## AUDIO
#Disable audio
VBoxManage modifyvm ${MACHINENAME} --audio none

## NETWORK
#Set Network
VBoxManage modifyvm ${MACHINENAME} --nic1 nat

# #Enable RDP
# VBoxManage modifyvm ${MACHINENAME} --vrde on
# VBoxManage modifyvm ${MACHINENAME} --vrdemulticon on --vrdeport 10001

#Start the VM
# VBoxHeadless --startvm ${MACHINENAME}