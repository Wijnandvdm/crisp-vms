#!/bin/bash

function configure_firewall(){
  sudo firewall-cmd --permanent --add-port=53/tcp
  sudo firewall-cmd --permanent --add-port=53/udp
  sudo firewall-cmd --reload
}

