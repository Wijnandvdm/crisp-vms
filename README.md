# REQUIREMENTS
## VM image
    You have to create a folder in the repository named "images", and download an .iso file (e.g. from https://ubuntu.com/download/desktop)
## Virtualbox
### Virtualbox program
    Download: https://www.virtualbox.org/wiki/Downloads
    You can encounter the following error: Oracle VM Virtualbox <version number> needs the Microsoft Visual C++ 2019 ... installed first.
    Fix for error: https://www.debugpoint.com/virtualbox-needs-microsoft-visual-c/
### Virtualbox Guest additions
    When you've installed Virtualbox, Guest Additions usually reside in "C:\Program Files\Oracle\VirtualBox"
    Copy file "VBoxGuestAdditions.iso" to images folder

## Git Bash
    Download: https://gitforwindows.org/
    You can encounter the following error: VBoxManage command not found
    Fix for error is add virtualbox folder to Path Env Vars: https://www.roelpeters.be/vboxmanage-is-not-recognized-and-how-to-solve-it/

## At this point manual actions after creating vm, preferably automated in future:
Add VSCode extensions in the following manner to post-install-script.sh: https://code.visualstudio.com/docs/editor/extension-marketplace#_command-line-extension-management

adjust example below and paste in a file called .gitconfig in user home directory (cd ~)
[user]
        name = WvdMeijs
        email = firstname.lastname@virtualsciences.nl
[credential]
        helper = store --file ~/.git-credentials
[push]
        default = current

adjust example below and paste in a file called .git-credentials in user home directory (cd ~):
https://firstletteroffirstnameandlastname:password@repo.virtualsciences.nl
https:/ssh-key-in-github@github.com

## Important side note on the SSH key in GitHub, first you create the key in GitHub.com, then you try to clone it with an empty git-credentials file. Log in via browser and it should autofill your git-credentials file.

install curl: sudo apt install curl
install azure cli: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#option-1-install-with-one-command

install docker: sudo snap install docker
https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket


install C# version 7.0: 
curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --version 7.0.400
sudo apt update && sudo apt install dotnet7

# Why
## This project has been started to allow for quickly and easily spinning up VMs
## This means that the standard way to run the create-vm.bash script has to result in a bare-bones VM
bash create-vm.sh
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


# for requesting the config that Vagrant creates, use:
vagrant ssh-config


# to check network adapters on windows, in powershell as admin:
Get-NetAdapter
