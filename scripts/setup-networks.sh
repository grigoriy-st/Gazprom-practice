#!/bin/bash

cat > /tmp/host-only.xml <<EOF
<network>
  <name>host-only</name>
  <ip address='192.168.100.1' netmask='255.255.255.0'/>
  <dhcp>
    <range start='192.168.100.10' end='192.168.100.100'/>
  </dhcp>
</network>
EOF

cat > /tmp/nat-net.xml <<EOF
<network>
  <name>nat-net</name>
  <forward mode='nat'/>
  <ip address='192.168.200.1' netmask='255.255.255.0'/>
  <dhcp>
    <range start='192.168.200.10' end='192.168.200.100'/>
  </dhcp>
</network>
EOF

for net in host-only nat-net; do
  if ! virsh net-info "$net" &>/dev/null; then
    echo "Создаём сеть $net..."
    sudo virsh net-define "/tmp/$net.xml"
    sudo virsh net-start "$net"
    sudo virsh net-autostart "$net"
  fi
done

rm /tmp/host-only.xml /tmp/nat-net.xml
