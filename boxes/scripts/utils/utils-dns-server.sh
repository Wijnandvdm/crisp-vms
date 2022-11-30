#!/bin/bash 

function subst_named(){
  local l1d=$(cut -d'.' -f2 <<< $1)
  local l2d=$(cut -d'.' -f1 <<< $1)

  local ip4_id1=$(cut -d'.' -f1 <<< $2)
  local ip4_id2=$(cut -d'.' -f2 <<< $2)
  local ip4_id3=$(cut -d'.' -f3 <<< $2)
  local ip4_id4=$(cut -d'.' -f4 <<< $2)

  local r_subnet=$ip4_id3.$ip4_id2.$ip4_id1
  local netid=$ip4_id1.$ip4_id2
  local subnetid=$ip4_id3
  local hostid=$ip4_id4
  
  local master_dns_ip=$3
  local named_template=$4
  local named_out=$5
  local dns_type=$6
  

  sed 's/{NETID}/'$netid'/g' $named_template | \
        sed 's/{SUBNETID}/'$subnetid'/g' | \
        sed 's/{R_SUBNET}/'$r_subnet'/g' | \
        sed 's/{HOSTID}/'$hostid'/g' | \
        sed 's/{L1D}/'$l1d'/g' | \
        sed 's/{L2D}/'$l2d'/g' | \
        sed 's/{DNS_TYPE}/'$dns_type'/g' | \
        sed 's/{MASTER_DNS_IP}/'$master_dns_ip'/g' | \
        tee $named_out
}

function install_dns() {
  local m_ip=$MASTER_DNS_IP
  local s_ip=$SLAVE_DNS_IP
  local domain=$DOMAIN
  local dns_type=$DNS_TYPE

  sudo yum update -y

  echo '### INSTALL DNS ###'
  if [[ $dns_type == 'master' || $dns_type == 'slave' ]]; then
    sudo yum install bind bind-utils -y
    sudo yum install net-tools -y
    sudo cp /opt/vm_config/dns/forward.vs-lab /var/named/
    sudo cp /opt/vm_config/dns/reverse.vs-lab /var/named/
    if [[ $dns_type == 'master' ]]; then
      sed '/{MASTER_DNS_IP}/d' $f_in | tee /tmp/named.bak
      subst_named $domain $m_ip "" /tmp/named.bak /tmp/named.conf $dns_type
    elif [[ $dns_type == 'slave' ]]; then
      subst_named $domain $s_ip $m_ip $f_in /tmp/named.conf $dns_type
    fi

    sudo sed -i 's/\r//' /tmp/named.conf
  
    sudo mv /tmp/named.conf /etc/named.conf

    echo '### ENABLE DNS ###'
    sudo systemctl enable named
    sudo systemctl start named

    echo '### ENSURE PERMISSIONS AND OWNERSHIP ###'
    sudo chgrp named -R /var/named
    sudo restorecon -rv /var/named
    sudo chown -v root:named /etc/named.conf
    sudo restorecon /etc/named.conf
  fi
  
  echo  '### CONFIGURE INTERFACES ###'
  sudo nmcli con mod "System eth0" ipv4.dns "$m_ip,$s_ip"
  sudo nmcli con mod "System eth1" ipv4.dns "$m_ip,$s_ip"

  echo '### DISABLE DHCP DNS ###'
  sudo nmcli con mod "System eth0" ipv4.ignore-auto-dns yes
  sudo nmcli con mod "System eth1" ipv4.ignore-auto-dns yes

  echo '### RESTART NETWORK SERVICE ###'
  sudo systemctl restart network
}


