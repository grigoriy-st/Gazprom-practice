# Cloud-init диск (для настройки пользователя и SSH)
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "cloud-init.iso"
  user_data = yamlencode({
    users = [{
      name                = "grigoriy-st"
      groups              = ["wheel"]
      shell               = "/bin/bash"
      sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
      ssh_authorized_keys = [var.ssh_public_key]
    }]
    runcmd     = ["systemctl enable --now sshd"]
    ssh_pwauth = false
  })
  meta_data = yamlencode({
    hostname = "arch-vm"
  })

  
}

resource "libvirt_volume" "os_image" {
  name   = "arch-vm.qcow2"
  # name   = "/mnt/Data_500GB/VMs/QEMU_KVM/Arch-Linux-x86_64-cloudimg.qcow2"
  capacity = 16106127360
  #os {
  #    type = "hvm"  # hardware virtual machine
  #}
  pool   = "default"
  # source = var.cloud_image_path
  #format = "qcow2"
}

resource "libvirt_domain" "arch-vm" {
  name   = "arch-vm"
  type   = "kvm"
  memory = 1024
  vcpu   = 1
  
  os = {
    type = "hvm"
    type_arch    = "x86_64"
    kernel_args  = "console=ttyS0 root=/dev/vda1"
  }

  devices = {
    disks = [
      {
        source = {
          file = {
            file = "${var.cloud_image_path}"
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]
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
    ]
    graphics = [ {
      vnc = {
      type = "vnc"
      listen = "127.0.0.1"
      autoport = false
      port = 9090
      }
    } ]
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

