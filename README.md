# This project has been started to allow for quickly and easily spinning up VMs
# This means that the standard way to run the create-vm.bash script has to result in a bare-bones VM
bash create-vm.bash
# All other functionalities that are added on, need to be found in ONE place and should be able to be turned off/on easily
# In this project, Virtualbox Version 6.1.30 r148432 (Qt5.6.2) is used

## SSH connection
# in VM, with command
ssh-keygen
# you generate a public/private rsa key pair
# open public file
# copy content and paste in new ssh key in GitHub
# configure SSO
# should be able to access GitHub from VM now
