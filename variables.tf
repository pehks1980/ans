variable "ansible_private_key_file" {
  description = "Path to the private key file"
  default     = "~/.ssh/ansible_key" # Optional default value
}

variable "ansible_public_key_file" {
  description = "Path to the private key file"
  default     = "~/.ssh/ansible_key.pub" # Optional default value
}


variable "ansible_hosts_file" {
  description = "Path to the hosts txt file"
  default     = "~/terraform/ans/ans_conf/hosts.txt" # Optional default value
}

variable "ansible_cfg_file" {
  description = "Path to the inventory cfg file"
  default     = "~/terraform/ans/ans_conf/inventory.cfg" # Optional default value
}
