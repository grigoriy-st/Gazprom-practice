#!/bin/bash

set -e

parted /dev/vda --script -- mklabel gpt
parted /dev/vda --script -- mkpart ESP fat32 1MiB 1025MiB
parted /dev/vda --script -- set 1 boot on
parted /dev/vda --script -- mkpart swap linux-swap 1025MiB 2049MiB
parted /dev/vda --script -- mkpart root ext4 2049MiB 9217MiB
parted /dev/vda --script -- mkpart home ext4 9217MiB 100%

mkfs.fat -F32 /dev/vda1          # /boot
mkswap /dev/vda2                 # swap
mkfs.ext4 /dev/vda3              # /
mkfs.ext4 /dev/vda4              # /home

mount /dev/vda3 /mnt
mkdir -p /mnt/{boot,home}
mount /dev/vda1 /mnt/boot
mount /dev/vda4 /mnt/home
swapon /dev/vda2

pacstrap /mnt base linux linux-firmware grub efibootmgr \
  git openssh tmux less more sudo qemu-guest-agent

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt <<'CHROOT'
  echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  
  ln -sf /usr/share/zoneinfo/Asia/Omsk /etc/localtime
  hwclock --systohc
  
  echo "arch-vm" > /etc/hostname
  
  useradd -m -G wheel -s /bin/bash grigoriy-st
  echo "grigoriy-st:12345678" | chpasswd
  
  sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
  
  systemctl enable sshd
  
  systemctl enable qemu-guest-agent
  
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  grub-mkconfig -o /boot/grub/grub.cfg
  
  echo "root:12345678" | chpasswd
CHROOT

arch-chroot /mnt <<'YAY'
  su - grigoriy-st -c 'cd ~ && \
    git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    makepkg -si --noconfirm && \
    rm -rf ~/yay-bin'
YAY

echo "=== Установка завершена! ==="
echo "Пользователь: grigoriy-st"
echo "Пароль: 12345678"
echo "Группа: wheel (sudo без пароля)"
