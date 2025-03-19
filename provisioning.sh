#!/bin/bash

sudo apt-get update && sudo apt-get install python3-pip -y # install pip
echo "alias python='python3'" >> /home/vagrant/.bashrc # useful alias
sudo -u vagrant mkdir -p /home/vagrant/repos # creation of repo directory as vagrant for correct permissions
pip install poetry # install poetry 
echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/vagrant/.bashrc # add poetry to PATH
sudo apt-get install docker.io -y # install docker
sudo usermod -aG docker vagrant # add vagrant user to docker group
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash # install azure cli
