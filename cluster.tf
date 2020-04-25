
# Base Disks
resource "libvirt_volume" "ubuntu_base" {
  count  = 1 + var.small-node-count + var.medium-node-count
  name   = "ubuntu18.04.qcow2"
  pool   = "images"
  source = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
  format = "qcow2"
}

# 50G Base Ubuntu images
resource "libvirt_volume" "ubuntu" {
  name           = "ubuntu-volume-${count.index}"
  base_volume_id = libvirt_volume.ubuntu_base[count.index].id
  pool           = "images"
  size           = 50 * 1073741824
  count          = 1 + var.small-node-count + var.medium-node-count
}


# Cloud Init
resource "libvirt_cloudinit_disk" "master" {
  name      = "cloudinit_master.iso"
  pool      = "images"
  user_data = data.template_file.master.rendered
}

resource "libvirt_cloudinit_disk" "node" {
  count     = 2
  name      = "cloudinit_node_${count.index}.iso"
  pool      = "images"
  user_data = data.template_file.node[count.index].rendered
}

# Master + Child Domains
resource "libvirt_domain" "k8s-master" {
  name   = "k8s-master"
  memory = "8192"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.master.id

  network_interface {
    addresses      = []
    hostname       = "k8s-master"
    bridge         = "kubenet"
    wait_for_lease = false
  }

  network_interface {
    addresses      = []
    hostname       = "k8s-master"
    bridge         = "br0"
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.ubuntu[0].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "k8s-node-small" {
  count  = 2
  name   = "k8s-node-${count.index + 1}"
  memory = "4096"
  vcpu   = var.small-node-count

  cloudinit = libvirt_cloudinit_disk.node[count.index].id

  network_interface {
    addresses      = []
    hostname       = "k8s-node-${count.index + 1}"
    bridge         = "kubenet"
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.ubuntu[count.index + 1].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "k8s-node-medium" {
  count  = var.medium-node-count
  name   = "k8s-node-${count.index + var.small-node-count}"
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.node[count.index + var.small-node-count].id

  network_interface {
    addresses      = []
    hostname       = "k8s-node-${count.index + var.small-node-count + 1}"
    bridge         = "kubenet"
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.ubuntu[count.index + var.small-node-count].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
