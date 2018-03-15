#!/bin/bash

echo "Install Digital Ocean Monitoring"
curl -sSL https://agent.digitalocean.com/install.sh | sh

echo "Install Docker"
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')

echo "Install K8s"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubernetes-cni=${cni_version}-00 kubelet=${k8s_version}-00 kubeadm=${k8s_version}-00 kubectl=${k8s_version}-00

echo "Set IPTables config for Weave networking"
sysctl net.bridge.bridge-nf-call-iptables=1
