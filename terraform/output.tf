output "bionic_lv_ip" {
  description = "IP of bionic-lv"
  value = libvirt_domain.bionic.network_interface[0].addresses[0]
}

output "focal_lv_ip" {
  description = "IP of focal-lv"
  value = libvirt_domain.focal.network_interface[0].addresses[0]
}

output "leap152_lv_ip" {
  description = "IP of leap152-lv"
  value = libvirt_domain.leap152.network_interface[0].addresses[0]
}