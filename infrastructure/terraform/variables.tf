variable "cloud_image_path" {
  description = "Путь к cloud-образу Arch Linux (.qcow2)"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH публичный ключ для доступа к ВМ"
  type        = string
}
