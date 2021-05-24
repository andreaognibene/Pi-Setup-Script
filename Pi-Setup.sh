#!/bin/bash
# Parameters: -h --hostname Hostname, -u --user Username, -i --ip Static IP, -g --gateway Gateway, -d --dns DNS server

# Default values if no parameters are provided. Change as needed.
HOSTNAME="Ogni-Pi4-1"
USER="ogni"
IP="192.168.1.3/24"			# With netmask, e.g. 192.168.1.2/24
GATEWAY="192.168.1.1"
DNS="192.168.1.2"

for arg in "$@"
do
    case $arg in
        -h|--hostname)
        HOSTNAME="$2"
        shift # Remove argument name from processing
        shift # Remove argument value from processing
        ;;
        -u|--user)
        USER="$2"
        shift # Remove argument name from processing
        shift # Remove argument value from processing
        ;;
        -i|--ip)
        IP="$2"
        shift # Remove argument name from processing
        shift # Remove argument value from processing
        ;;
		-g|--gateway)
        GATEWAY="$2"
        shift # Remove argument name from processing
        shift # Remove argument value from processing
        ;;
		-d|--dns)
        DNS="$2"
        shift # Remove argument name from processing
        shift # Remove argument value from processing
        ;;
    esac
done

# Change hostname.
hostnamectl set-hostname ${HOSTNAME}

# Add user and add to SUDO group.
adduser ${USER}
usermod -aG sudo ${USER}

# Basic UFW setup.
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
ufw logging on

# Static IP setup.
wget https://raw.githubusercontent.com/andreaognibene/Pi-Setup-Script/main/01-netcfg.yaml -P /etc/netplan/
sed -i "s|%IP%|${IP}|g" /etc/netplan/01-netcfg.yaml
sed -i "s|%GATEWAY%|${GATEWAY}|g" /etc/netplan/01-netcfg.yaml
sed -i "s|%DNS%|${DNS}|g" /etc/netplan/01-netcfg.yaml
wget https://raw.githubusercontent.com/andreaognibene/Pi-Setup-Script/main/99-disable-network-config.cfg -P /etc/cloud/cloud.cfg.d/
rm /etc/netplan/50-cloud-init.yaml
netplan apply

# Update APT repository.
apt update && apt upgrade -y

# Reboot.
reboot
