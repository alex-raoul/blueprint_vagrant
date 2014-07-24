#!/bin/bash
echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.eth1.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p