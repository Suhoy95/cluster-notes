#!/bin/bash
set -x

function killNetwork() # name
{
    name=$1
    virsh net-destroy $name
    virsh net-undefine $name
}

killNetwork mpi-admin
killNetwork mpi-isolated
