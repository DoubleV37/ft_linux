#!/bin/sh

sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev dwarves gawk libdw-dev

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.2.tar.xz

tar -xf linux-6.17.2.tar.xz
sudo mv linux-6.17.2 /usr/src/kernel-6.17.2-vviovi
cd kernel-6.17.2-vviovi

cp /boot/config-$(uname -r) .config

scripts/config --set-str LOCALVERSION -vviovi
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS

sudo make olddefconfig

# make menuconfig #perso la config

echo "Le nombre de threads de votre CPU est : $(nproc)"
echo "Compilation"
make -j$(nproc)

sudo make modules_install
sudo make install

sudo awk '/^#?GRUB_TIMEOUT_STYLE=/ { $0 = "GRUB_TIMEOUT_STYLE=menu"}1' /etc/default/grub > grub.tmp && sudo mv grub.tmp /etc/default/grub
sudo awk '/^#?GRUB_TIMEOUT=/{$0 = "GRUB_TIMEOUT=5"}1' /etc/default/grub > grub.tmp && sudo mv grub.tmp /etc/default/grub

sudo update-grub

echo "Redémarrage nécessaire"
