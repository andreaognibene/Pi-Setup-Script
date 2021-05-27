#!/bin/bash
# Ubuntu Server 20.04 LTS on Raspberry Pi4
# Parameters: -h --hostname Hostname, -u --user Username, -i --ip Static IP, -g --gateway Gateway, -d --dns DNS server

# Default values if no parameters are provided.
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

echo
echo "HOSTNAME: ${HOSTNAME}"
echo "USER: ${USER}"
echo "IP: ${IP}"
echo "GATEWAY: ${GATEWAY}"
echo "DNS: ${DNS}"

echo
read -r -p "Continue? [Y/n] " input
case $input in
	[yY][eE][sS]|[yY])
 		echo;;

    	[nN][oO]|[nN])
 		echo "Aborting."
		exit 1;;

    	*)
 		exit 1;;
esac

# Change hostname.
echo "Changing host name to ${HOSTNAME}..."
hostnamectl set-hostname ${HOSTNAME}
echo "Done."
echo

# Add user and add to SUDO group.
echo "Creating new user ${USER}..."
adduser ${USER}
usermod -aG sudo ${USER}
echo "Done."
echo

# Basic UFW setup.
echo "Setting up UFW..."
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
ufw logging on
echo "Done."
echo

# Static IP setup.
echo "Setting up static IP ${IP}..."
wget https://raw.githubusercontent.com/andreaognibene/Pi-Setup-Script/main/01-netcfg.yaml -P /etc/netplan/
sed -i "s|%IP%|${IP}|g" /etc/netplan/01-netcfg.yaml
sed -i "s|%GATEWAY%|${GATEWAY}|g" /etc/netplan/01-netcfg.yaml
sed -i "s|%DNS%|${DNS}|g" /etc/netplan/01-netcfg.yaml
wget https://raw.githubusercontent.com/andreaognibene/Pi-Setup-Script/main/99-disable-network-config.cfg -P /etc/cloud/cloud.cfg.d/
rm /etc/netplan/50-cloud-init.yaml
netplan apply
echo "Done."
echo

# Root password setup.
echo "Changing root password..."
passwd root
echo "Done."
echo

# SSH root login setup.
echo "Allowing SSH root login..."
sed -i "s|#PermitRootLogin without-password|PermitRootLogin yes|g" /etc/ssh/sshd_config
systemctl restart sshd
echo "Done."
echo

# SSH keys generation.
echo "Generating public and private keys in /.ssh folder..."
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
ssh-keygen -f .ssh/${HOSTNAME}_root -P ""
cat .ssh/${HOSTNAME}_root.pub >> .ssh/authorized_keys
echo "Done."
echo

read -r -p "Run APT update and upgrade? [Y/n] " input
case $input in
	[yY][eE][sS]|[yY])
 		echo "Yes";;

    	[nN][oO]|[nN])
 		echo "Aborting."
		exit 1;;

    	*)
 		exit 1;;
esac

# Update APT repository.
apt update && apt upgrade -y

# Reboot.
reboot
