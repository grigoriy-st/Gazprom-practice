variable "vm_count_app" {
    description = "VM quantity"
    type = number
    default = 2
}

variable "vm_count_monitor" {
    description = "Monitoring VM quantity"
    type = number
    default = 1
}

variable "vm_memory" {
    description = "RAM quantity"
    type = number
    default = 1
}

variable "vm_vcpu" {
    description = "vCPU quantity"
    type = number
    default = 1
}

variable "cloud_image_path" {
    description = "Cloud image path"
    type = string
}

variable "ssh_public_key" {
    description = "SSH key"
    type = string
}

