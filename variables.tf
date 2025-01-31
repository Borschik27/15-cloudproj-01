variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "default_zone" {
  type        = string
}

variable "vms_ssh_root_key" {
  type        = string 
}

variable "vms_ssh_root_key_file" {
  type        = string 
}

variable "ppkyc" {
  type        = string
  description = "Path to key"
}

variable "platform_id" {
  type        = string
  description = "Platform ID"
}

variable "image_family" {
  type        = string
  description = "ISO Img"
}

variable "vm_user" {
  description = "Username for the VM user"
  type        = string
}

variable "vm_user_password" {
  description = "Password for the VM user"
  type        = string
}

variable "vm_u_group" {
  description = "User group for the VM user"
  type        = string
}

variable "vm_u_shell" {
  description = "Shell for the VM user"
  type        = string
}

variable "sudo_cloud_init" {
  description = "Sudo permissions for the user"
  type        = string
}

variable "pack_list" {
  description = "List of packages to install via Cloud-init"
  type        = list(string)
  default     = []
}
