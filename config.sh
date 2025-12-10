#!/bin/bash

export MY_LOGIN="vviovi"

export DISK="/dev/sdb"
export LFS_PART="${DISK}3"
export SWAP_PART="${DISK}2"
export BOOT_PART="${DISK}1"

export LFS="/mnt/lfs"
export LFS_TGT=$(uname -m)-lfs-linux-gnu
export LC_ALL=POSIX

export PATH=$LFS/tools/bin:$PATH

export MAKEFLAGS="-j$(nproc)"

export SRC_DIR=$LFS/sources
export TOOLS_DIR=$LFS/tools
