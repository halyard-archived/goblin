#!/usr/bin/env bash

set -euo pipefail

echo 'Sanity checking'
[[ -n "$(vgs)" ]] && vgs --noheadings -o vg_name | xargs -n1 vgremove -f
[[ -n "$(pvs)" ]] && pvs --noheadings -o pv_name | xargs -n1 pvremove -f
ping -c1 -W1 8.8.8.8
timedatectl set-ntp true

echo 'Setting up devices'
parted -s /dev/sda 'mklabel msdos' 'unit %' 'mkpart primary 0 100'
pvcreate /dev/sda1
vgcreate vg1 /dev/sda1

echo 'Setting up LVs'
lvcreate -L 10G -Wy --yes -n root vg1
lvcreate -L 1G -Wy --yes -n swap vg1
mkfs.ext4 /dev/vg1/root
mkswap /dev/vg1/swap

echo 'Mounting devices'
mount /dev/vg1/root /mnt
swapon /dev/vg1/swap

echo 'Bootstrapping initial packages'
pacstrap /mnt base base-devel grub puppet git linux linux-firmware vim lvm2
genfstab -p /mnt >> /mnt/etc/fstab

echo 'Enabling lvm2 for mkinitcpio'
sed -i 's/^HOOKS="base udev/& lvm2/' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

echo 'Setting up GRUB'
arch-chroot /mnt grub-install --recheck /dev/sda
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo 'Set basic locale settings'
ln -sfv /usr/share/zoneinfo/Etc/UTC /mnt/etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo 'Setting the password'
password="$(head -c256 /dev/urandom | md5sum | head -c24)"
echo "root:$password" | arch-chroot /mnt chpasswd

echo 'Bootstrap goblin'
arch-chroot /mnt git clone --recurse-submodules https://github.com/halyard/goblin /opt/goblin
arch-chroot /mnt /opt/goblin/meta/puppet-run

echo 'Rebooting'
reboot
