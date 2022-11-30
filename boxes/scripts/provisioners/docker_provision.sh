#!/bin/bash
cd /vagrant
printf "%b\n" "config=$2"
printf "%b\n Starting provisioner in: "`pwd`
cur_dir="$(dirname "$0")"
source /vagrant/scripts/utils/utils-yaml.sh
source /vagrant/scripts/utils/utils-command.sh

key=$1
cfg=$2
# Get config from yaml
eval $(parse_yaml "${cfg}" "${key}")

eval HOSTNAME=\$$key\_vm_hostname
eval SERVICE_DOCKER_INSTALL=\$$key\_services_docker_install_script

#INSECURE_KEY=$(curl -i https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub | grep ssh-rsa)
#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant:vagrant@localhost -p3326

sudo hostnamectl set-hostname $HOSTNAME

printf "Starting provisioner for the $BOX virtual box."
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


### Make sure the interface for the default gateway is up
TIMER=0
while  ! ip route | grep -oP 'default via .+ dev eth0' ; do
  echo "interface not up, will try again in 1 second";
  sleep 1;
  let TIMER=TIMER+1
  if [ $TIMER == 100 ]; then
    echo "TIMEOUT WHILE WAITING FOR NETWORK!"
    break
  fi
done

### Docker
# todo: test for docker-compose
if [[ ! $SERVICE_DOCKER_INSTALL == "" ]]; then
    if [ -x "$(command -v docker)" ]; then
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo systemctl start containerd 
    else
        echo "Install docker"
        sh $SERVICE_DOCKER_INSTALL
        sudo systemctl enable docker
    fi  
fi

### Start continers with Docker Compose
COMPOSE_FILE=""
eval COMPOSE_FILE=\$$key\_services_docker_compose_file
if [[ ! $COMPOSE_FILE == "" ]]; then
  sudo systemctl start docker
  sudo systemctl start containerd  
  sudo docker-compose -f $COMPOSE_FILE up -d
fi

