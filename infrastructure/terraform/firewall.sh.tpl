#!/bin/sh
iptables -F INPUT
iptables -P INPUT DROP

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
