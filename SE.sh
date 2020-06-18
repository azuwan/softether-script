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
wget -O /lib/systemd/system/vpnserver.service https://raw.githubusercontent.com/azuwan/softether-script/master/vpnserver.service

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=3128/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 143"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/Clrkz/VPSAutoScrptz/master/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1


[dropbear]
accept = 443
connect = 127.0.0.1:3128

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# finishing
service dropbear restart
service squid3 restart

END
