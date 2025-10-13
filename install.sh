#!/bin/sh

sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev dwarves gawk libdw-dev

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.2.tar.xz

tar -xf linux-6.17.2.tar.xz
cd linux-6.17.2

cp /boot/config-$(uname -r) .config

scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS

make olddefconfig

# make menuconfig #perso la config

echo "Le nombre de threads de votre CPU est : $(nproc)"
echo "Compilation"
make -j$(nproc)

sudo make modules_install
sudo make install


sudo update-grub

echo "Redémarrage nécessaire"
