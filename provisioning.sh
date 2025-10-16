#!/bin/bash
UV_VERSION="0.8.0"
DATABRICKS_VERSION=0.268.0

apt-get update # update apt packages (one could add apt-get upgrade -y to upgrade all packages, but this take way more time)
echo "alias python='python3'" >> /home/vagrant/.bashrc # useful alias
sudo -u vagrant mkdir -p /home/vagrant/repos # creation of repo directory as vagrant for correct permissions
curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh # install uv
mv /root/.local/bin/uv /usr/local/bin/ # since uv is installed as root, we need to move it to a system path
apt-get install docker.io -y # install docker
usermod -aG docker vagrant # add vagrant user to docker group
curl -sL https://aka.ms/InstallAzureCLIDeb | bash # install azure cli
apt install unzip # install unzip (necessary for databricks cli installation)
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh \
  | sed "s/^VERSION=\"[^\"]*\"/VERSION=\"${DATABRICKS_VERSION}\"/" \
  | sh # install databricks cli