# REQUIREMENTS
## Virtualbox
    Download: https://www.virtualbox.org/wiki/Downloads
    You can encounter the following error Oracle VM Virtualbox <version number> needs the Microsoft Visual C++ 2019 ... installed first.
    Fix for error: https://www.debugpoint.com/virtualbox-needs-microsoft-visual-c/
## Git Bash
    Download: https://gitforwindows.org/

# Why
## This project has been started to allow for quickly and easily spinning up VMs
## This means that the standard way to run the create-vm.bash script has to result in a bare-bones VM
. create-vm.sh
## All other functionalities that are added on, need to be found in ONE place and should be able to be turned off/on easily
## In this project, Virtualbox Version 7.0.6 is used

# SSH connection
## in VM, with command
ssh-keygen
## you generate a public/private rsa key pair
## open public file
## copy content and paste in new ssh key in GitHub
## configure SSO
## should be able to access GitHub from VM now
