provider "libvirt" {
  uri = "qemu:///system"
}

data "template_file" "user_data" {
  template = <<EOF
users:
  - name: grigoriy-st
    groups: wheel
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
      - ${var.ssh_public_key}
runcmd:
  - systemctl enable --now sshd
ssh_pwauth: false
EOF
}

data "template_file" "meta_data" {
  template = <<EOF
instance-id: ${uuid()}
local-hostname: ${var.name}
EOF
}

resource "local_file" "cloud_init_iso" {
  content         = data.template_file.user_data.rendered
  filename        = "/tmp/${var.name}-cloud-init.iso"
  file_permission = "0644"
}

# Network
resource "libvirt_network" "default" {
  count       = 0 # Мы используем существующую сеть 'default'
  name        = "tf-net"
  addresses   = ["192.168.123.0/24"]
  dhcp_start  = "192.168.123.10"
  dhcp_end    = "192.168.123.100"
}

# Volume
resource "libvirt_volume" "data_disk" {
  name           = "data-disk.qcow2"
  size           = 5368709120 # 5 GB
  pool           = "default"
  format         = "qcow2"
}

resource "libvirt_domain" "app_vm" {
  count       = var.vm_count_app
  name        = "app-vm-${count.index + 1}"
  memory      = var.vm_memory
  vcpu        = var.vm_vcpu

  cloudinit = local_file.cloud_init_iso.filename

  network_interface {
    network_name = "default"
    hostname     = "app-vm-${count.index + 1}"
  }

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "none"
  }
}

# Monitoring vm
resource "libvirt_domain" "monitoring_vm" {
  count       = var.vm_count_monitoring
  name        = "monitoring-vm-${count.index + 1}"
  memory      = var.vm_memory
  vcpu        = var.vm_vcpu

  cloudinit = local_file.cloud_init_iso.filename

  network_interface {
    network_name = "default"
    hostname     = "monitoring-vm-${count.index + 1}"
  }

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "none"
  }
}

# OS Volume
resource "libvirt_volume" "os_image" {
  count       = var.vm_count_app + var.vm_count_monitoring
  name        = "os-image-${count.index}.qcow2"
  source      = var.cloud_image_path
  pool        = "default"
  format      = "qcow2"
}
