#!/bin/bash
cd /vagrant
printf "%b\n" "config=$2"
printf "%b\n Starting provisioner in: "`pwd`
cur_dir="$(dirname "$0")"
source /vagrant/scripts/utils/utils-yaml.sh
source /vagrant/scripts/utils/utils-dns-server.sh
source /vagrant/scripts/utils/utils-dns-client.sh
source /vagrant/scripts/utils/utils-firewall.sh
source /vagrant/scripts/utils/utils-command.sh
source /vagrant/scripts/utils/utils-users.sh
key=$1
cfg=$2
# Get config from yaml
eval $(parse_yaml "${cfg}" "${key}")

eval HOSTNAME=\$$key\_vm_hostname
eval NEWUSER=\$$key\_vm_user
eval BOX=\$$key\_vm_box
eval GUEST_IP=\$$key\_network_ip
eval DOMAIN=\$$key\_network_domain
eval MASTER_DNS_IP=\$$key\_services_dns_nameserver1_ip
eval SLAVE_DNS_IP=\$$key\_services_dns_nameserver2_ip
eval DNS_TYPE=\$$key\_services_dns_type
eval SERVICE_DOCKER_INSTALL=\$$key\_services_docker_install_script
eval SECRETS_FILES=\$$key\_secrets_ssh_key_files

f_in="/opt/vm_config/dns/named.conf" 
f_out="/etc/named.conf" 

sudo hostnamectl set-hostname $HOSTNAME

### SERVICES 
### Install DNS
if [[ $BOX == *"centos"* && ( $DNS_TYPE == "master" || $DNS_TYPE == "slave" ) ]]; then
  install_dns $DNS_TYPE
  configure_firewall
elif [[ ( $BOX == *"ubuntu"* && $DNS_TYPE == "client" ) ]]; then
  install_resolvconf $MASTER_DNS_IP $SLAVE_DNS_IP "local" $DOMAIN
elif [[ ( $BOX == *"centos"* && $DNS_TYPE == "client" ) ]]; then
  nmcli_set_dns $MASTER_DNS_IP $SLAVE_DNS_IP "eth0"
  nmcli_set_dns $MASTER_DNS_IP $SLAVE_DNS_IP "eth1"
fi


install(){
  sudo apt update 
  sudo apt install terminator
  #sudo apt upgrade -y
  if [ ! -x "$(command -v xfce-about)" ]; then
    sudo apt install xubuntu-core --quiet -y
  fi

  if [ ! -x "$(command -v x2goversion)" ]; then
    sudo apt-get install x2goserver x2goserver-xsession --quiet -y
    echo "see https://www.digitalocean.com/community/tutorials/how-to-set-up-a-remote-desktop-with-x2go-on-ubuntu-18-04"   
    sudo sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1
    sudo echo "X2GO_NXAGENT_DEFAULT_OPTIONS=\" -extension BIG-REQUESTS\"" >> /etc/x2go/x2goagent.options
    sudo service x2goserver restart
  fi

  if [ ! -x "$(command -v code)" ]; then
    sudo snap install code --classic --user-data-dir /home/vagrant
  fi

  # install chromium 
  if [ ! -x "$(command -v chromium-browser)" ]; then
    sudo apt install chromium-browser -y
  fi
  # PowerShell
  if [ ! -x "$(command -v pwsh)" ]; then
    # Install pre-requisite packages.
    sudo apt-get install -y wget apt-transport-https software-properties-common
    # Download the Microsoft repository GPG keys
    wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
    # Register the Microsoft repository GPG keys
    sudo dpkg -i packages-microsoft-prod.deb
    # Update the list of packages after we added packages.microsoft.com
    sudo apt-get update
    # Install PowerShell
    sudo apt-get install -y powershell
  fi
  
  if [ ! -x "$(command -v python3-venv)" ]; then
    # Install python virtualenv
    sudo apt-get install python3-venv
    python3 -m venv ~/vm_venv
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo apt install python3.9
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
  fi
  if [ ! -x "$(command -v teams)" ]; then
    cd /tmp
    wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.5153_amd64.deb
    dpkg -i teams_1.3.00.5153_amd64.deb
  fi
   
  if [ ! -x "$(command -v azuredatastudio)" ]; then
    curl -L https://sqlopsbuilds.azureedge.net/stable/13e362762762e5cb76a5c8afd2bc650f48c2d3d8/azuredatastudio-linux-1.28.0.deb --output /tmp/azuredatastudio.deb
    sudo dpkg -i /tmp/azuredatastudio.deb
    sudo rm /tmp/azuredatastudio.deb
  fi

  if [ ! -x "$(command -v batch-explorer)" ]; then
    curl -L https://github.com/Azure/BatchExplorer/releases/download/v2.11.0-stable.541/batch-explorer_2.11.0-stable.541_amd64.deb --output /tmp/batch-explorer.deb
    sudo dpkg -i /tmp/batch-explorer.deb
    sudo rm /tmp/batch-explorer.deb
  fi

  if [ ! -x "$(command -v storage-explorer)" ]; then
    sudo snap install storage-explorer
    snap connect storage-explorer:password-manager-service :password-manager-service
  fi 

  if [ ! -x "$(command -v dbeaver)" ]; then
    sudo snap install dbeaver-ce
  fi

   sudo chown -R vagrant:vagrant /home/vagrant
   sudo su vagrant -
   code --install-extension ms-vscode.vscode-node-azure-pack --user-data-dir /home/vagrant --force
   code --install-extension ms-mssql.mssql --user-data-dir /home/vagrant --force
   code --install-extension fernandoescolar.vscode-solution-explorer --user-data-dir /home/vagrant --force
   code --install-extension ms-dotnettools.csharp --user-data-dir /home/vagrant --force
   code --install-extension ms-toolsai.jupyter --user-data-dir /home/vagrant --force
   code --install-extension ms-python.python --user-data-dir /home/vagrant --force
   # Install-Package Azure.Identity
   #sudo snap install dotnet-runtime-31 --classic
   sudo snap unalias dotnet
   sudo snap install dotnet-sdk --classic --channel=6.0  
   sudo snap alias dotnet-runtime-6.dotnet dotnet
   export DOTNET_ROOT=/snap/dotnet-sdk/current
}

remove(){
  sudo apt purge xubuntu-icon-theme xfce4-* -y
  sudo apt autoremove -y
}

### TODO: add snippet in config/bash/bashrc.part to /etc/bash.bashrc

install


