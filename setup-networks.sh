#!/bin/bash
set -e
set -x

function setUpPersistentNetwork() # name
{
  name=$1
  virsh net-define network/$name.xml
  virsh net-start $name
  virsh net-autostart $name
}

name=mpi-admin
cat <<XML_TEMPLATE > network/$name.xml
<network>
  <name>$name</name>
  <uuid>$(uuid)</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr10' stp='on' delay='0'/>
  <mac address='52:54:00:36:6c:3c'/>
  <ip address='10.20.30.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.20.30.2' end='10.20.30.254'/>
    </dhcp>
  </ip>
</network>
XML_TEMPLATE
setUpPersistentNetwork $name

name=mpi-isolated
cat <<XML_TEMPLATE > network/$name.xml
<network>
  <name>$name</name>
  <uuid>$(uuid)</uuid>
  <bridge name='virbr20' stp='on' delay='0'/>
  <ip address='10.10.10.1' netmask='255.255.255.0'>
  </ip>
</network>
XML_TEMPLATE
setUpPersistentNetwork $name
