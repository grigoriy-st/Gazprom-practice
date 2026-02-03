# Cloud-init диск (для настройки пользователя и SSH)
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "cloud-init.iso"
  count = var.vm_count
  user_data = yamlencode({
    users = [{
      name                = "grigoriy-st"
      groups              = ["wheel"]
      shell               = "/bin/bash"
      sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
      ssh_authorized_keys = [var.ssh_public_key]
    }]
    runcmd     = [
      "systemctl enable --now sshd",
      "sudo /etc/firewall.sh",
    ]
    ssh_pwauth = false
  })
  meta_data = yamlencode({
    hostname = "arch-vm"
  })
  
}
resource "local_file" "firewall_script" {
  content = templatefile("${path.module}/firewall.sh.tpl", {
    allowed_ips = ["0.0.0.0/0"]
  })
  filename = "/tmp/firewall.sh"
}

resource "null_resource" "apply_firewall" {
  depends_on = [local_file.firewall_script]

  provisioner "local-exec" {
    command = "sudo chmod +x /tmp/firewall.sh && sudo /tmp/firewall.sh"
  }
}

resource "libvirt_volume" "os_image" {
  name   = "arch-vm.qcow2"
  pool     = "Gazprom_Practice_Storage"
  capacity = 16106127360


}

resource "libvirt_domain" "arch-vm" {
  count = var.vm_count
  name   = "arch-vm-${count.index}"
  type   = "kvm"
  memory = 1024
  vcpu   = 1
  
  os = {
    type = "hvm"
    type_arch    = "x86_64"
    kernel_args  = "console=ttyS0 root=/dev/vda1"
  }

  devices = {

    disk = {
      cdrom     = true
      volume_id = libvirt_cloudinit_disk.commoninit[count.index].id
    },
    filesystems = [ {
      driver = {
          cdrom = true

          format = "qcow2"
      } }
    ],
    disks = [
      {
        source = {
          file = {
            file = "${var.cloud_image_path}"
          }
        },
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ], 
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default"
          }
        }
      }
    ], 
    graphics = [ {
      vnc = {
      type = "vnc"
      listen = "127.0.0.1"
      autoport = false
      port = 9090
      }
    } ], 
    consoles = [{
      tapy = "pty"
      target_port = "0"
      target_type = "serial"
    }]
  }
  
}

resource "libvirt_domain" "kernel_boot" {
  name   = "kernel-boot-vm"
  memory = 1024
  memory_unit   = "MiB"
  vcpu   = 1
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    kernel       = "/boot/vmlinuz"
    initrd       = "/boot/initrd.img"
    kernel_args  = "console=ttyS0 root=/dev/vda1"
  }
  
}

