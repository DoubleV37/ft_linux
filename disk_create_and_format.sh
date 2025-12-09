#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
	echo "Error: you have to run this script with sudo." >&2
	exit 1
fi

DISK="/dev/sdb"
LFS=/mnt/lfs

echo "***Create one part boot (500M), one part swap (2G) and one root part***"

sfdisk $DISK << EOF
,500M,L,*
,2G,S
,,L
EOF

echo "***Format part***"

mkfs.ext4 ${DISK}1
mkswap ${DISK}2
mkfs.ext4 ${DISK}3

echo "***Mount sdb parts to install packages on them.***"

mkdir -p $LFS
mount ${DISK}3 $LFS

mkdir -p $LFS/boot
mount ${DISK}1 $LFS/boot

swapon ${DISK}2

echo "***Create and format finished:***"

lsblk $DISK
