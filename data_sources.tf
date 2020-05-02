data "template_file" "master" {
  template = "${file("${path.module}/templates/kube.node.tpl")}"
  vars = {
    public_ip_address = "192.168.5.87/22"
    gateway           = "192.168.4.1"
    password          = var.login-password
    hostname          = "k8s-master"
  }
}

data "template_file" "node" {
  count    = var.small-node-count + var.medium-node-count + 1
  template = "${file("${path.module}/templates/kube.node.tpl")}"
  vars = {
    public_ip_address = "192.168.5.${90 + count.index}/22"
    gateway           = "192.168.4.1"
    password          = var.login-password
    hostname          = "k8s-node-${count.index + 1}"
  }
}
