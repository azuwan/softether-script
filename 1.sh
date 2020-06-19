#!/bin/bash
#SoftEther VPN Server install for Ubuntu/Debian.
# Copyleft (C) 2020 azuwan.com - All Rights Reserved
# Permission to copy and modify is granted under the CopyLeft license

#Update the OS if not already done.
apt-get -y update && apt-get -y upgrade

#Install essentials
apt-get -y install build-essential libssl-dev g++ openssl libpthread-stubs0-dev gcc-multilib

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
cd vpnserver && make

#Move up and then copy Softether libs to /usr/local
cd ..
mv vpnserver /usr/local
cd /usr/local/vpnserver/
chmod 600 *
chmod 700 vpncmd vpnserver
./vpnserver start

#Housekeeping
rm -f /usr/local/vpnserver/Authors.txt
rm -f /usr/local/vpnserver/Makefile
rm -f /usr/local/vpnserver/ReadMeFirst_Important_Notices_*.txt
rm -f /usr/local/vpnserver/ReadMeFirst_License.txt
rm -f /root/softether-vpnserver-*.tar.gz

exit 0
