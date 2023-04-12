#!/bin/bash
# safe bash
set -o errexit -o noclobber -o nounset -o pipefail -o xtrace -o errtrace
# check command line arguments
if [ $# -ne 2 ]
then
   echo -e "Usage:\n\t $0 <redhat_installation_image.iso> <ssh_public_key_file>" 1>&2
   exit 1
fi
dvd_iso="$1"
echo "Check installation image \"${dvd_iso}\""
eval $(VBoxManage unattended detect --iso "${dvd_iso}" --machine-readable)
if [ "$OSTypeId" = 'RedHat_64' -a "$OSVersion" = '7' ]
then
   echo "The installation image \"${dvd_iso}\" is Ok"
else
   echo "Error: The installation image must be RedHat 7 64bit or so like (CentOS, for instance)" 1>&2
   exit 2
fi
ssh_public_key="$2"
echo "Check ssh public key \"${ssh_public_key}\""
if [ -r "${ssh_public_key}" ]
then
   ssh_fingerprint="$(ssh-keygen -l -f "${ssh_public_key}" | cut -d ' ' -f 2)"
else
   echo "Error: The ssh public key file is not readable" 1>&2
   exit 3
fi

readonly vm_name='TestVirtualBox'
readonly vboxvm_vdi=~/"Library/VirtualBox/${vm_name}/${vm_name}.vdi"

VBoxManage createvm --name "${vm_name}" --ostype RedHat_64 --register
VBoxManage modifyvm "${vm_name}" --memory 600 --vram=10 --boot1 dvd --boot2 disk --boot3 none --boot4 none --rtcuseutc on --graphicscontroller vmsvga --firmware bios --defaultfrontend headless --nic1 nat --nictype1 virtio --mouse ps2 --keyboard ps2 --audio none --cpus 2
VBoxManage setextradata "${vm_name}" 'GUI/ScaleFactor' 2
VBoxManage createmedium disk --filename "${vboxvm_vdi}" --size 3072
VBoxManage storagectl "${vm_name}" --name 'DiskController' --add sas --hostiocache on --bootable on
VBoxManage storagectl "${vm_name}" --name 'DVDController' --add sata --hostiocache on --bootable on
VBoxManage storageattach "${vm_name}" --storagectl 'DiskController' --type hdd --port 0 --device 0 --medium "${vboxvm_vdi}"
VBoxManage storageattach "${vm_name}" --storagectl 'DVDController' --type dvddrive --port 0 --device 0 --medium "${dvd_iso}"
VBoxManage unattended install "${vm_name}" --iso="${dvd_iso}" --hostname="${vm_name}.${vm_name}" --package-selection-adjustment='minimal' --script-template="redhat.kickstart" --post-install-command="mkdir -m 700 \"\${MY_TARGET}/root/.ssh\" && echo '$(cat "${ssh_public_key}")' >>\"\${MY_TARGET}/root/.ssh/authorized_keys\"" --start-vm='headless' --extra-install-kernel-parameters='net.ifnames=0 biosdevname=0 ks=cdrom:/ks.cfg' # --locale='ru_RU' --time-zone="Europe/Moscow"