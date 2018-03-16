#!/bin/bash
sudo kubeadm init --config=/tmp/kube-config.yml
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Weave networking plugin
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# Add Digital Ocean cloud deployment manager
kubectl apply -f /tmp/cloud-deployment-manager.yml
