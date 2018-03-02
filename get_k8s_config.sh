#!/bin/bash

mkdir -p $HOME/.kube 
scp root@$(terraform output web_ip):/etc/kubernetes/admin.conf $HOME/.kube/do-k8s
KUBECONFIG=$HOME/.kube/do-k8s kubectl config set-cluster kubernetes --server=https://kubernetes:6443
