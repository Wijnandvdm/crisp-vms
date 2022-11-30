#!/bin/bash
MACHINENAME=scorched-earth

# Download linux.iso
if [ ! -f ./images/linux.iso ]; then
    echo "image not found, downloading image..."
    # not the right url yet
    # curl -o images/linux.iso https://releases.ubuntu.com/20.04.5/ubuntu-20.04.5-live-server-amd64.iso
else
    echo "image already exists, continuing..."
fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Linux_64" --register --basefolder `pwd`
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory 1024 --vram 128
VBoxManage modifyvm $MACHINENAME --nic1 nat

# #Create Disk and connect Linux Iso
# VBoxManage createhd --filename `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi --size 80000 --format VDI
# VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
# VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi
# VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
# VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/images/linux.iso
# VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

# #Enable RDP
# VBoxManage modifyvm $MACHINENAME --vrde on
# VBoxManage modifyvm $MACHINENAME --vrdemulticon on --vrdeport 10001

#Start the VM
VBoxHeadless --startvm $MACHINENAME