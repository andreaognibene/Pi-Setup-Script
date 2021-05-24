#!/bin/bash

sudo su

# Change hostname.
hostnamectl set-hostname Ogni-Pi4-1

# Add user.
adduser ogni
usermod -aG sudo ogni

# Setup UFW.
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
ufw logging on

# Setup static IP.
wget https://github.com/andreaognibene/Ogni-Pi4-1-Setup-Script/raw/main/01-netcfg.yaml -P /etc/netplan/
netplan apply

# Update APT repository.
apt update && apt upgrade -y