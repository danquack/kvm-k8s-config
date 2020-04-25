#cloud-config
disable_root: 0
growpart:
  mode: auto
  devices: ['/']

# User Auth
ssh_pwauth: 1
password: ${ password }
chpasswd: { expire: False }

# Host info
hostname: ${ hostname }

# Software
package_update: true
apt:
  sources:
    kubernetes:
      source: "deb https://apt.kubernetes.io/ kubernetes-xenial main"
      keyserver: "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
      keyid: 54A6 47F9 048D 5688 D7DA 2ABE 6A03 0B21 BA07 F4FB
        
        

packages:
    - netplan.io
    - docker.io
    - apt-transport-https
    - kubelet=1.15.10-00
    - kubeadm=1.15.10-00

# Config
write_files:
- owner: root:root
  path: /etc/netplan/50-cloud-init.yaml 
  content: |
    network:
        version: 2
        renderer: networkd
        ethernets:
            ens3:
                dhcp4: true

- owner: root:root
  path: /etc/docker/daemon.json
  content: |
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "100m"
      },
      "storage-driver": "overlay2"
    }
bootcmd:
    - mkdir -p /etc/systemd/system/docker.service.d
    - systemctl daemon-reload
    - systemctl restart docker
    - kubeadm config images pull
runcmd:
    - netplan apply
    - swapoff -a
    - modprobe br_netfilter ip_tables
    - echo "1" > /proc/sys/net/ipv4/ip_forward
    - echo "1" > /proc/sys/net/bridge/bridge-nf-call-iptables
    - systemctl enable docker

final_message: "The system is finally up, after $UPTIME seconds"