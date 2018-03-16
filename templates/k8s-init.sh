#!/bin/bash
#sed -i 's#\(Environment="KUBELET_EXTRA_ARGS=.*\)\("$\)#\1 --node-ip=${node_ip}\2#' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#systemctl daemon-reload
#systemctl restart kubelet.service

kubeadm init --config=/tmp/kube-config.yml
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Weave networking plugin
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# Add Digital Ocean cloud deployment manager
kubectl apply -f /tmp/cloud-deployment-manager.yml
