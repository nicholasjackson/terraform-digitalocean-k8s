#!/bin/bash
sudo kubeadm init --kubernetes-version=${version} --token=${token} --apiserver-advertise-address=${advertise_address}
export KUBECONFIG=/etc/kubernetes/admin.conf

# Install Weave networking plugin
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# Add Digital Ocean cloud deployment manager
kubectl apply -f /tmp/cloud-deployment-manager.yml
