output "app_vm_ips" {
  value = [for vm in libvirt_domain.app_vm : vm.network_interface[0].addresses[0]]
}

output "monitoring_vm_ips" {
  value = [for vm in libvirt_domain.monitoring_vm : vm.network_interface[0].addresses[0]]
}
