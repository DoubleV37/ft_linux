#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo "Error: you have to run this script with sudo." >&2
	exit 1
fi

source ./config.sh

echo "Download sources packages..."

if [ -f "toolchain_list.txt" ]; then
	wget -c -i toolchain_list.txt -P $SRC_DIR
else
	echo "Error: toolchain_list.txt not found"
	exit 0;
fi


