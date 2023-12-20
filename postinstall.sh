#!/bin/sh

ln -sf /usr/share/zoneinfo/Europe/Kirov /etc/localtime
hwclock --systohc --utc

sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

echo "LANG=ru_RU.UTF-8" >>/etc/locale.conf

printf "KEYMAP=ru\nFONT=cyr-sun16" >>/etc/vconsole.conf

echo "sergey-desktop" >>/etc/hostname

pacman -S grub efibootmgr neovim sudo pipewire pipewire-alsa pipewire-pulse wireplumber noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-noto-nerd

grub-install

grub-mkconfig -o /boot/grub/grub.cfg

systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse
