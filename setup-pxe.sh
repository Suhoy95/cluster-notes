#!/bin/bash
set -x
set -e

ISO=CentOS-7-x86_64-DVD-1708.iso

mkdir -p ftp/

if !(mount | grep $ISO); then
    sudo mount -o loop $ISO /mnt
fi

if !(ls ftp/* > /dev/null); then
    cp -r /mnt/* ftp/
    sudo chmod -R 755 ftp/
fi

sudo umount /mnt

cat <<FTP_CONFIG > vsftpd.conf
# Please see vsftpd.conf.5 for all compiled in defaults.
listen=NO
listen_ipv6=YES

# Доступ для анонимного входа (самое важное)
anonymous_enable=YES
anon_root=`pwd`/ftp

local_enable=YES
#write_enable=YES
#local_umask=022
#anon_upload_enable=YES
#anon_mkdir_write_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
#chown_uploads=YES
#chown_username=whoever
#xferlog_file=/var/log/vsftpd.log
#xferlog_std_format=YES
#idle_session_timeout=600
#data_connection_timeout=120
#nopriv_user=ftpsecure
#async_abor_enable=YES
#ascii_upload_enable=YES
#ascii_download_enable=YES
#ftpd_banner=Welcome to CentOS7 image.
#deny_email_enable=YES
#banned_email_file=/etc/vsftpd.banned_emails
#chroot_local_user=YES
#chroot_local_user=YES
#chroot_list_enable=YES
#chroot_list_file=/etc/vsftpd.chroot_list
#ls_recurse_enable=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
utf8_filesystem=YES
FTP_CONFIG
sudo chown root:root vsftpd.conf
sudo mv vsftpd.conf /etc
sudo systemctl restart vsftpd


mkdir -p tftp/
mkdir -p tftp/pxelinux.cfg
mkdir -p tftp/centos7
cp ftp/images/pxeboot/initrd.img tftp/centos7
cp ftp/images/pxeboot/vmlinuz tftp/centos7

cp /usr/lib/PXELINUX/pxelinux.0 tftp/
cp /usr/lib/syslinux/modules/bios/*.c32 tftp/
cp pxeboot.msg tftp/pxelinux.cfg/

cat <<PXE_CONFIG > tftp/pxelinux.cfg/default
# Perform a local boot by default
default local
# Always prompt
DEFAULT menu.c32
PROMPT 0
# Display the bootup message
display pxelinux.cfg/pxeboot.msg
# Boot automatically after 3 seconds in tenths of a second
timeout 300
LABEL local
    MENU LABEL local
    localboot 0
PXE_CONFIG

for i in $(seq $NUMBER_OF_NODES); do
    cat <<PXE_CONFIG >> tftp/pxelinux.cfg/default
LABEL node$i
    MENU LABEL node^$i
    KERNEL centos7/vmlinuz
    APPEND initrd=centos7/initrd.img ks=ftp://10.20.30.1/node$i-ks.cfg
    IPAPPEND 2
PXE_CONFIG
done

i=1
for mac in $(cat macs.txt); do
    cat <<PXE_CONFIG > tftp/pxelinux.cfg/01-$mac
default autoinstall
PROMPT 0
display pxelinux.cfg/pxeboot.msg
timeout 30
LABEL local
    MENU LABEL local
    localboot 0
LABEL autoinstall
    MENU LABEL autoinstall
    KERNEL centos7/vmlinuz
    APPEND initrd=centos7/initrd.img ks=ftp://10.20.30.1/node$i-ks.cfg
    IPAPPEND 2
PXE_CONFIG
let 'i=i + 1'
done

cat <<TFTP_CONFIG > tftpd-hpa
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="`pwd`/tftp"
TFTP_ADDRESS="10.20.30.1:69"
TFTP_OPTIONS="--secure"
TFTP_CONFIG
sudo mv tftpd-hpa /etc/default/
sudo systemctl restart tftpd-hpa
