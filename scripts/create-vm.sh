#!/bin/bash
set -e

if [ $# -eq 0 ]; then
  echo "Использование: $0 <имя-вм> [память] [ядер]"
  exit 1
fi

VM_NAME="$1"
RAM="${2:-2048}"
VCPUS="${3:-2}"
DISK_SIZE="15G"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIR="$SCRIPT_DIR/vms"
CLOUD_IMG="/mnt/Data_500GB/VMs/QEMU_KVM/Arch-Linux-x86_64-cloudimg.qcow2"
DISK_PATH="$VM_DIR/${VM_NAME}.qcow2"
ISO_PATH="$VM_DIR/ci-${VM_NAME}.iso"

# Создаём каталог для ВМ
mkdir -p "$VM_DIR"

# Проверка образа
if [ ! -f "$CLOUD_IMG" ]; then
  echo "Cloud-образ не найден: $CLOUD_IMG"
  exit 1
fi

# Проверка существования ВМ
if virsh list --all --name | grep -q "^${VM_NAME}$"; then
  echo "ВМ '$VM_NAME' уже существует"
  exit 1
fi

echo "Создаём ВМ: $VM_NAME"

# Диск
sudo qemu-img create -f qcow2 -b "$CLOUD_IMG" -F qcow2 "$DISK_PATH" "$DISK_SIZE"

# Meta-data 
cat > "$VM_DIR/meta-data.${VM_NAME}" <<EOF
instance-id: $(uuidgen)
local-hostname: $VM_NAME
EOF

sudo cloud-localds -v "$ISO_PATH" "$SCRIPT_DIR/user-data" "$VM_DIR/meta-data.${VM_NAME}"

sudo virt-install \
  --name "$VM_NAME" \
  --memory "$RAM" \
  --vcpus "$VCPUS" \
  --disk path="$DISK_PATH",format=qcow2,bus=virtio \
  --disk path="$ISO_PATH",device=cdrom \
  --os-variant archlinux \
  --graphics vnc,listen=0.0.0.0 \
  --console pty,target_type=serial \
  --network network=default,model=virtio \
  --import \
  --noautoconsole

echo "'$VM_NAME' запущена!"
echo "Консоль: sudo virsh console $VM_NAME"
echo "VNC: порт автоматический (virsh vncdisplay $VM_NAME)"
