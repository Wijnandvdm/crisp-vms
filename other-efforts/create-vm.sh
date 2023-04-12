#!/bin/bash

#Source of inspiration:
# https://andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/

# Download linux.iso
if [ ! -f ./images/linux.iso ]; then
    echo "image not found, downloading image..."
    curl -o images/linux.iso https://releases.ubuntu.com/20.04.5/ubuntu-20.04.5-live-server-amd64.iso
else
    echo "image found, continuing..."
fi

# GLOBAL PARAMETERS
MACHINENAME=tabula-rasa
PRESWORKDIR=`pwd`/vms/${MACHINENAME}

#Create VM
VBoxManage createvm --name ${MACHINENAME} --ostype "Ubuntu_64" --register --basefolder `pwd`/vms

## SYSTEM
#Supply VM with 4GB working memory, set processors and set boot order
VBoxManage modifyvm ${MACHINENAME} --memory 4096 --cpus 4 --boot1 disk --boot2 dvd --boot3 none

## DISPLAY
#Supply VM with 256 video memory, enable VRDP, enable multiple connections and set port
VBoxManage modifyvm ${MACHINENAME} --vram 256 --vrde on --vrdemulticon on --vrdeport 11853

## STORAGE
#Create Disk
VBoxManage createmedium --filename ${PRESWORKDIR}/${MACHINENAME}-disk.vmdk --size 131072 --format VMDK
VBoxManage storagectl ${MACHINENAME} --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach ${MACHINENAME} --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium ${PRESWORKDIR}/${MACHINENAME}-disk.vmdk

## AUDIO
#Disable audio
VBoxManage modifyvm ${MACHINENAME} --audio none

## NETWORK
#Set Network
VBoxManage modifyvm ${MACHINENAME} --nic1 nat

## ADDITIONAL SETTINGS
#Enable bidirectional clipboard and drag and drop, only possible when Guest Additionals are installed
# VBoxManage modifyvm ${MACHINENAME} --clipboard bidirectional --draganddrop bidirectional



## GitHub ssh keys:
# https://cli.github.com/manual/gh_ssh-key
# https://docs.github.com/en/enterprise-cloud@latest/authentication/authenticating-with-saml-single-sign-on/about-authentication-with-saml-single-sign-on

#Start the VM
# VBoxHeadless --startvm ${MACHINENAME}