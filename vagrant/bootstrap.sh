#!/usr/bin/env bash

apt-get update
apt-get install -y curl network-manager apparmor docker.io jq
curl -sLo installer.sh https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh
sed -i "s/read answer.*/answer=n/g" installer.sh
sed -i "/sleep 10/d" installer.sh
sed -i "s/IP_ADDRESS=.*/IP_ADDRESS=192.168.50.4/g" installer.sh
sudo bash installer.sh