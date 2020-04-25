provider "libvirt" {
  uri = "qemu+ssh://root@192.168.5.100/system?socket=/var/run/libvirt/libvirt-sock"
}