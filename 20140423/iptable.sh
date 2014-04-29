#!/bin/bash

# ------------------------
# iptables setting
# ------------------------
iptables -F
iptables -X

# ポリシー
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

# IPSpoofing
#iptables -A INPUT -i eth0 -s 127.0.0.1/8 -j DROP
#iptables -A INPUT -i eth0 -s 10.0.0.0/8 -j DROP
#iptables -A INPUT -i eth0 -s 172.16.0.0/12 -j DROP
#iptables -A INPUT -i eth0 -s 192.168.0.0/16 -j DROP
#iptables -A INPUT -i eth0 -s 192.168.0.0/24 -j DROP

# Ping of Death
iptables -N PING_ATTACK
iptables -A PING_ATTACK -m length --length :85 -j ACCEPT
iptables -A PING_ATTACK -j LOG --log-prefix "[IPTABLES PINGATTACK] : " --log-level=debug
iptables -A PING_ATTACK -j DROP
iptables -A INPUT -p icmp --icmp-type 8 -j PING_ATTACK

# Ping Flood
iptables -A PING_ATTACK -p icmp --icmp-type 8 -m length --length :85 -m limit --limit 1/s --limit-burst 4 -j ACCEPT

# Smurf 攻撃
#iptables -A INPUT -d 255.255.255.255 -j DROP
#iptables -A INPUT -d 224.0.0.1 -j DROP
#iptables -A INPUT -d 192.168.56.255 -j DROP

# Smurf 踏み台
#sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1 > /dev/null
#sed -i '/# Disable Broadcast Ping/d' /etc/sysctl.conf
#sed -i '/net.ipv4.icmp_echo_ignore_broadcasts/d' /etc/sysctl.conf
#echo "# Disable Broadcast Ping" >> /etc/sysctl.conf
#echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf

# SYN flood攻撃対策でSYN cookiesを有効に設定
#sysctl -w net.ipv4.tcp_syncookies=1 > /dev/null
#sed -i '/# Enable SYN Cookie/d' /etc/sysctl.conf
#sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
#echo "# Enable SYN Cookie" >> /etc/sysctl.conf
#echo "net.ipv4.tcp_syncookies=1" >> /etc/sysctl.conf

# 特定のIPだけ許可
if [ -s /root/deny_ip ]; then
    for ip in `cat /root/deny_ip`
    do
	echo "accept ip="$ip
	iptables -A INPUT -s $ip -j ACCEPT
    done
fi

# log
# iptables -A INPUT -j LOG --log-prefix "IPTABLES_INPUT_LOG : " --log-level=info
# iptables -A INPUT -j LOG --log-prefix "DROP : " --log-level=debug
iptables -A INPUT -j LOG --log-prefix "DROP:" --log-level warning
#iptables -N LOGGING
#iptables -A LOGGING -j LOG --log-level warning --log-prefix "DROP:" -m limit
#iptables -A LOGGING -j DROP
#iptables -A INPUT -j LOGGING
#iptables -A OUTPUT -j LOGGING


