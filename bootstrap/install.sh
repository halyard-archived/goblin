#!/usr/bin/env bash

set -euo pipefail

echo 'Sanity checking'
[[ -n "$(vgs)" ]] && vgs --noheadings -o vg_name | xargs -n1 vgremove -f
[[ -n "$(pvs)" ]] && pvs --noheadings -o pv_name | xargs -n1 pvremove -f
ping -c1 -W1 8.8.8.8
timedatectl set-ntp true

echo 'Setting up devices'
BLOCK="$(lsblk | grep disk | grep -v archiso | awk '{print $1}')"
if [[ "$BLOCK" == "sda" ]] ; then
    PARTITION="${BLOCK}2"
elif [[ "$BLOCK" == "nvme0n1" ]] ; then
    PARTITION="${BLOCK}p2"
else
    echo "Found bad block device!"
    exit 1
fi
parted -s "/dev/$BLOCK" 'mklabel gpt' 'mkpart efi 1MiB 512MiB' 'mkpart lvm 512MiB 100%' 'set 1 esp on'
pvcreate --force "/dev/${PARTITION}"
vgcreate vg1 "/dev/${PARTITION}"

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
sed -i 's/^HOOKS=(base udev/& lvm2/' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P

echo 'Setting up GRUB'
sed -i 's/^GRUB_PRELOAD_MODULES="\(.*\)"$/GRUB_PRELOAD_MODULES="\1 lvm"/' /mnt/etc/default/grub
arch-chroot /mnt grub-install --recheck "/dev/$BLOCK"
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo 'Set basic locale settings'
ln -sfv /usr/share/zoneinfo/Etc/UTC /mnt/etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

echo "Enable basic networking"
arch-chroot /mnt systemctl enable systemd-networkd
arch-chroot /mnt systemctl enable systemd-resolved
cat > /mnt/etc/systemd/network/default.network <<EOF
[Match]
Name=en*

[Network]
DHCP=yes
EOF

echo 'Setting the password'
password="$(head -c256 /dev/urandom | md5sum | head -c24)"
echo "root:$password" | arch-chroot /mnt chpasswd

echo 'Bootstrap goblin'
sed -i 's/Arch Linux/ArchLinux/' /mnt/etc/os-release
curl -sLo /mnt/root/kickstart https://git.io/halyard-kickstart
arch-chroot /mnt bash /root/kickstart

echo 'Rebooting'
reboot
