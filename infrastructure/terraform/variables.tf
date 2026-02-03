variable "cloud_image_path" {
  description = "Path to cloud-image Arch Linux (.qcow2)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH key"
  type        = string
}

variable "vm_count" {
  description = "Number of vms"
  default     = 3
  type        = string
}
