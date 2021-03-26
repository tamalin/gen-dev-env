provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "gen_dev_env" {
  name = "gen-dev-env"
  type = "dir"
  path = "/var/lib/libvirt/gen-dev-env"
}

resource "libvirt_volume" "bionic_qcow2" {
  name   = "bionic-qcow2"
  pool   = libvirt_pool.gen_dev_env.name
  source = "https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "focal_qcow2" {
  name   = "focal-qcow2"
  pool   = libvirt_pool.gen_dev_env.name
  // source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "leap152_qcow2" {
  name   = "leap152-qcow2"
  pool   = libvirt_pool.gen_dev_env.name
  // source = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.2/images/openSUSE-Leap-15.2-OpenStack.x86_64.qcow2"
  source = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.2/images/openSUSE-Leap-15.2.x86_64-NoCloud.qcow2"
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "leap_qemu_agent_init" {
  name           = "leap_qemu_agent_init.iso"
  user_data      = local.leap_qemu_agent_cloud_init
  network_config = local.leap_netplan_network_config
  pool           = libvirt_pool.gen_dev_env.name
}

resource "libvirt_cloudinit_disk" "ubuntu_qemu_agent_init" {
  name           = "ubuntu_qemu_agent_init.iso"
  user_data      = local.ubuntu_qemu_agent_cloud_init
  network_config = local.ubuntu_netplan_network_config
  pool           = libvirt_pool.gen_dev_env.name
}

resource "libvirt_domain" "bionic" {
  name   = "bionic-lv"
  memory = "1024"
  vcpu   = 2
  qemu_agent = true

  cpu = {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.ubuntu_qemu_agent_init.id

  network_interface {
    bridge = "br0"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.bionic_qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  boot_device {
    dev = [ "hd", "network"]
  }
}


resource "libvirt_domain" "focal" {
  name   = "focal-lv"
  memory = "1024"
  vcpu   = 2
  qemu_agent = true

  cpu = {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.ubuntu_qemu_agent_init.id

  network_interface {
    bridge = "br0"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.focal_qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  boot_device {
    dev = [ "hd", "network"]
  }
}

resource "libvirt_domain" "leap152" {
  name   = "leap152-lv"
  memory = "1024"
  vcpu   = 2
  qemu_agent = true

  cpu = {
    mode = "host-passthrough"
  }

  cloudinit = libvirt_cloudinit_disk.leap_qemu_agent_init.id

  network_interface {
    bridge = "br0"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.leap152_qcow2.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  boot_device {
    dev = [ "hd", "network"]
  }
}

resource "ansible_host" "bionic" {
  inventory_hostname = "bionic-lv"
  groups = ["devenv", "ubuntu", "python3"]
  vars = {
    ansible_host = libvirt_domain.bionic.network_interface[0].addresses[0]
  }
}

resource "ansible_host" "focal" {
  inventory_hostname = "focal-lv"
  groups = ["devenv", "ubuntu", "python3"]
  vars = {
    ansible_host = libvirt_domain.focal.network_interface[0].addresses[0]
  }
}

resource "ansible_host" "leap152" {
  inventory_hostname = "leap152-lv"
  groups = ["devenv", "opensuse", "leap", "python3"]
  vars = {
    ansible_host = libvirt_domain.leap152.network_interface[0].addresses[0]
  }
}

resource "ansible_group" "devenv" {
  inventory_group_name = "devenv"
  vars = {
    ansible_user = "devuser"
  }
}

resource "ansible_group" "python" {
  inventory_group_name = "python"
  vars = {
    ansible_python_interpreter = "/usr/bin/python"
  }
}

resource "ansible_group" "python3" {
  inventory_group_name = "python3"
  vars = {
    ansible_python_interpreter = "/usr/bin/python3"
  }
}