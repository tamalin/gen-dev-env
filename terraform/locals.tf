locals {
    user_id_rsa_pub = file(pathexpand(var.ssh_pub_key))
}

locals {
    ubuntu_qemu_agent_cloud_init = <<EOF
#cloud-config
# vim: syntax=yaml
#
# ***********************
# 	---- for more examples look at: ------
# ---> https://cloudinit.readthedocs.io/en/latest/topics/examples.html
# ******************************
#
# This is the configuration syntax that the write_files module
# will know how to understand. encoding can be given b64 or gzip or (gz+b64).
# The content will be decoded accordingly and then written to the path that is
# provided.
#
# Note: Content strings here are truncated for example purposes.
users:
  - default
  - name: devuser
    gecos: Dev User
    primary_group: devuser
    groups: [adm, users, audio, cdrom, dialout, floppy, video, plugdev, dip, netdev]
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$O7cjY/cAt1z2x$bjzFMobd1/iiD4fLwi55yZzijdHPQNGcdnnTsM6vx35P6ThV6eqVdKf01Q.cPqkr3hRpAwPVpHXgYUGVCUu1E/
    ssh_authorized_keys:
      - ${local.user_id_rsa_pub}
    sudo: ALL=(ALL:ALL) NOPASSWD:ALL

package_update: true
package_upgrade: ${var.package_upgrade}
package_reboot_if_required: true

packages:
  - qemu-guest-agent

runcmd:
  - [ systemctl, daemon-reload ]
  - [ systemctl, enable, qemu-guest-agent ]
  - [ systemctl, start, --no-block, qemu-guest-agent ]
EOF

    ubuntu_netplan_network_config = <<EOF
version: 2
renderer: networkd
ethernets:
  ens3:
    dhcp4: true
    dhcp4: true
EOF
}

locals {
  leap_qemu_agent_cloud_init = <<EOF
#cloud-config
# vim: syntax=yaml
#
# ***********************
# 	---- for more examples look at: ------
# ---> https://cloudinit.readthedocs.io/en/latest/topics/examples.html
# ******************************
#
# This is the configuration syntax that the write_files module
# will know how to understand. encoding can be given b64 or gzip or (gz+b64).
# The content will be decoded accordingly and then written to the path that is
# provided.
#
# Note: Content strings here are truncated for example purposes.
users:
  - default
  - name: devuser
    gecos: Dev User
    primary_group: devuser
    groups: [users, audio, cdrom, dialout, video]
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$O7cjY/cAt1z2x$bjzFMobd1/iiD4fLwi55yZzijdHPQNGcdnnTsM6vx35P6ThV6eqVdKf01Q.cPqkr3hRpAwPVpHXgYUGVCUu1E/
    ssh_authorized_keys:
      - ${local.user_id_rsa_pub}
    sudo: ALL=(ALL:ALL) NOPASSWD:ALL

package_update: true
package_upgrade: ${var.package_upgrade}
package_reboot_if_required: true
EOF
    leap_netplan_network_config = <<EOF
network:
  version: 1
  config:
  - type: physical
    name: eth0
    subnets:
      - type: dhcp
EOF
}
