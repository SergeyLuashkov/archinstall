#!/bin/sh

mount "$1" /mnt

btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

umount /mnt
mount -o noatime,compress=zstd,space_cache=v2,subvol=@root "$1" /mnt
mkdir /mnt/boot
mkdir /mnt/var
mkdir /mnt/home
mkdir /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,subvol=@var "$1" /mnt/var
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home "$1" /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots "$1" /mnt/.snapshots
