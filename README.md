# KVM K8s Config
A module that builds single node k8s clusters with various size nodes on kvm. This repository powers the infrastructure behind the domain danquack.dev.

### Basic Architecture
1 - k8s master

X - small nodes 2x4

X - medium nodes 4x8

### Variables:
- *__small-node-count__* - total number of small nodes
- *__medium-node-count__* - total number of small nodes
- *__login-password__* - login password defined in user data scripts for ubuntu user


### Dependencies
Installable through Homebrew:
- cdrtools
- libvirt
- terraform-provider-libvirt