#!/bin/bash
set -x

# networks
function killNetwork() # name
{
    name=$1
    virsh net-destroy $name
    virsh net-undefine $name
}

killNetwork mpi-admin
killNetwork mpi-isolated

# pxe
rm -rf tftp/{pxelinux.0,centos7,pxelinux.cfg}
rm -rf ftp/{node*-ks.cfg,centos}
