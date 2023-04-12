#!/bin/bash

# Set the VM name and disk location
VMNAME="ubuntu-vm"
DISKLOCATION="vms/virtualdisks/"

# Download the Ubuntu ISO image
ISOURL="http://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-desktop-amd64.iso"
ISOFILE="images/linux.iso"

if [ ! -f ./images/linux.iso ]; then
    echo "image not found, downloading image..."
    curl -o images/linux.iso $ISOURL
else
    echo "image found, continuing..."
fi

# Create a new VM in VirtualBox
VBoxManage createvm --name $VMNAME --ostype Ubuntu_64 --register

# Configure the VM
VBoxManage modifyvm $VMNAME --memory 2048 --vram 128 --cpus 2 --audio none --usb off --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage storagectl $VMNAME --name "IDE Controller" --add ide
VBoxManage storageattach $VMNAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISOFILE
VBoxManage storagectl $VMNAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage createmedium disk --filename "${DISKLOCATION}/${VMNAME}.vdi" --size 10000 --format VDI
VBoxManage storageattach $VMNAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${DISKLOCATION}/${VMNAME}.vdi"


# # Start the VM
# VBoxHeadless --startvm $VMNAME

VBoxManage unattended install $VMNAME \
--user=username --password=1234 \
--country=US --time-zone=EST \
--language=en-US \
--hostname=ubuntu18server.kifarunix.com \
--iso=$ISOFILE \
--start-vm=gui