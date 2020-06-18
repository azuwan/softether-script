#!/bin/bash
#SoftEther VPN Server install for Ubuntu/Debian.
# Copyleft (C) 2020 azuwan.com - All Rights Reserved
# Permission to copy and modify is granted under the CopyLeft license

#Update the OS if not already done.
apt-get -y update && apt-get -y upgrade

#Install essentials
apt-get -y install build-essential libssl-dev g++ openssl libpthread-stubs0-dev gcc-multilib dnsmasq

#Backup dnsmasq conf
mv /etc/dnsmasq.conf /etc/dnsmasq.conf-bak

#disable UFW firewall
ufw disable

#Stop UFW
service ufw stop

#Flush Iptables
iptables -F && iptables -X

#Use wget to copy it directly onto the server.
wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.34-9745-beta/softether-vpnserver-v4.34-9745-beta-2020.04.05-linux-x64-64bit.tar.gz

#Extract it. Enter directory and run make and agree to all license agreements:
tar xvf softether-vpnserver-*.tar.gz
cd vpnserver
printf '1\n1\n1\n' | make

#Move up and then copy Softether libs to /usr/local
cd ..
mv vpnserver /usr/local
cd /usr/local/vpnserver/
chmod 600 *
chmod 700 vpncmd
chmod 700 vpnserver

#Create systemd init file for Softether VPN service
wget -O /lib/systemd/system/vpnserver.service https://whattheserver.me/softether-scripts/vpnserver.service

echo "Complete"
