data "template_file" "master" {
  template = "${file("${path.module}/templates/master.yml.tpl")}"
  vars = {
    public_ip_address = "192.168.5.85/22"
    gateway           = "192.168.4.1"
    password          = var.login-password
    hostname          = "k8s-master"
  }
}

data "template_file" "node" {
  count    = var.small-node-count + var.medium-node-count
  template = "${file("${path.module}/templates/node.yml.tpl")}"
  vars = {
    password = var.login-password
    hostname = "k8s-node-${count.index + 1}"
  }
}
