#!/bin/bash
# Add the node ip to kubelet config
sed -i \
  's#\(Environment="KUBELET_EXTRA_ARGS=.*\)\("$\)#\1--node-ip=${node_ip}\2#' \
  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet.service

# Join the cluster
sudo kubeadm join --token=${token} --discovery-token-unsafe-skip-ca-verification ${master_ip}:6443

