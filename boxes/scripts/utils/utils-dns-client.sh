#!/bin/bash -x

### install_resolvconf
### param 1: Primary nameserver IPv4 address (192.168.xxx.yyy)
### param 2: Secondary nameserver IPv4 address
### param 3: Searchdomain i.e. 'local'
### param 4: testdomain: internal test top-level domain to test correct resolution i.e. "jumbo.dlt.dev.local"

function install_resolvconf(){
  local ns1=$1
  local ns2=$2
  local searchdomain=$3
  local testdomain=$4

  sudo apt install resolvconf
  sudo systemctl enable resolvconf.service
  sudo systemctl start resolvconf.service
  sudo echo "nameserver $ns1" | sudo tee /etc/resolvconf/resolv.conf.d/head
  sudo echo "nameserver $ns2" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
  sudo echo "search $searchdomain " | sudo tee -a /etc/resolvconf/resolv.conf.d/head
  sudo sed -i 's/\r//' /etc/resolvconf/resolv.conf.d/head
  sudo resolvconf --enable-updates
  sudo resolvconf -u
  sudo systemctl restart systemd-resolved
  sudo systemctl restart networking
}

function nmcli_set_dns(){
  local ns1=$1
  local ns2=$2
  local if=$3
  echo  '### CONFIGURE INTERFACES ###'
  sudo nmcli con mod "System $if" ipv4.dns "$ns1,$ns2"

  echo '### DISABLE DHCP DNS ###'
  sudo nmcli con mod "System $if" ipv4.ignore-auto-dns yes

  echo '### RESTART NETWORK SERVICE ###'
  sudo systemctl restart network
}

function test_dns(){
  local __return_var=$1
  local test_domain=$2
  local test_ip=$3
  local assert_var=$4
  local entry_type=$5
  local result="false"
  if [[ ( -n "$__return_var" && -n "$test_domain" && -n "$test_ip" && -n "$assert_var" && -n "$entry_type" ) ]]; then
    result="$(dig @$test_ip +short $entry_type  $test_domain|grep '^'$assert_var'$')"
    if [[ -n $result ]]; then
      eval $__return_var=true
    else
      eval $__return_var=false
    fi
  else
          echo "test_dns() "
          echo "arguments: "
          echo "  - return_var:  Variable name for return value (String)"
          echo "  - test_domain: Domain to search for nameservers (String)"
          echo "  - test_ip:     IPv4 address of the DNS to query (String)"
          echo "  - assert_var:  Nameserver FQN to evaluate against (String)"
          echo "  - entry_type:  NS; A; CNAME; MX (String)"
          echo " example: test_dns myresult jumbo.dlt.dev.local 192.168.33.10 ns1.jumbo.dlt.dev.local NS"
          echo " example: test_dns myresult centos.jumbo.dlt.dev.local 192.168.33.10 ns1.jumbo.dlt.dev.local CNAME"
          echo
  fi
}

