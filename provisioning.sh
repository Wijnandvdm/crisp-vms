#!/bin/bash
UV_VERSION="0.8.0"

sudo apt-get update # update apt packages (one could add sudo apt-get upgrade -y to upgrade all packages, but this take way more time)
echo "alias python='python3'" >> /home/vagrant/.bashrc # useful alias
sudo -u vagrant mkdir -p /home/vagrant/repos # creation of repo directory as vagrant for correct permissions
curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh # install uv
sudo apt-get install docker.io -y # install docker
sudo usermod -aG docker vagrant # add vagrant user to docker group
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash # install azure cli
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh # install databricks cli