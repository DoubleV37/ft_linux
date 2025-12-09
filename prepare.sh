#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
	echo "Error: you have to run this script with sudo." >&2
	exit 1
fi

source ./config.sh

echo "Prepare folders"

mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var,tools,sources,lib64}

chmod -v a+wt $LFS/sources

cd $LFS/sources


