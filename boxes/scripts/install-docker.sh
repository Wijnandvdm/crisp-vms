#!/bin/bash

### install docker-ce

cd /tmp
/bin/sh /opt/vm_scripts/get-docker.sh
sudo usermod -aG docker vagrant
sudo systemctl start docker
sudo systemctl start containerd
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
