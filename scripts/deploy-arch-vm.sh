#!/bin/bash

VM_NAME="arch-vm-$(date +%Y%m%d-%H%M)"
DISK_SIZE="15G"
RAM="2048"
VCPUS="2"

sudo qemu-img create -f qcow2 /var/lib/libvirt/images/${VM_NAME}.qcow2 ${DISK_SIZE}

sudo virt-install \
  --name ${VM_NAME} \
  --memory ${RAM} \
  --vcpus ${VCPUS} \
  --disk path=/var/lib/libvirt/images/${VM_NAME}.qcow2,format=qcow2,bus=virtio \
  --os-variant archlinux \
  --graphics vnc \
  --console pty,target_type=serial \
  --cdrom "/mnt/Data_500GB/VMs/ISOs/Arch/archlinux-2025.10.01-x86_64.iso" \
  --network bridge=virbr0,model=virtio \
  --rng /dev/urandom

echo "ВМ '${VM_NAME}' запущена. Подключитесь к консоли:"
echo "  sudo virsh console ${VM_NAME}"
