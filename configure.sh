#!/bin/bash

echo "This is README. Read. Don't execute"
exit -1


sudo apt-get install tftpd-hpa \
    pxelinux \
    vsftpd \
    python3-jinja2 \

# tftp and ftp configs will be overriden
mkdir -p backup
cp /etc/default/tftpd-hpa backup/
cp /etc/vsftpd.conf backup/
