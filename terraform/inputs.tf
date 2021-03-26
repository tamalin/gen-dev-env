variable "ssh_pub_key" {
  description = "Path to a SSH public key that will added to the .ssh/authorized_keys files of created instances. (Will be pathexpand()'d so use of '~' is permitted.)"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "package_upgrade" {
  description = "Whether to automatically all packages when bringing up an instance."
  type = bool
  default = false
}
