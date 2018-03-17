#!/bin/bash
function tunnel_k8s_api {
  # If a tunnel is running kill it before connection
  pid=$(pgrep -f "ssh -i .* -f root@.* -L 6443:.*")
  if [[ ! $pid -eq "" ]]; then
    kill $pid
  fi

  ssh -i $(terraform output k8s_private_key) -f root@$(terraform output k8s_master_public_ip) -L 6443:$(terraform output k8s_master_public_ip):6443 -N

  if [ $? != 0 ]; then
    exit $?
  fi

  echo ""
  echo "Started SSH tunnel to K8s master, the API is now available at https://localhost:6443"
}

function tunnel_k8s_stop {
  pid=$(pgrep -f "ssh -i .* -f root@.* -L 6443:.*")
  if [[ $pid -eq "" ]]; then
    echo "Unable to find running ssh tunnel"
    exit 2
  fi

  kill $pid
  
  echo ""
  echo "Stopped ssh tunnel"
}

function get_k8s_config {
  mkdir -p $HOME/.kube 
  scp -i $(terraform output k8s_private_key) root@$(terraform output k8s_master_public_ip):/etc/kubernetes/admin.conf $HOME/.kube/do-k8s
  KUBECONFIG=$HOME/.kube/do-k8s kubectl config set-cluster kubernetes --server=https://localhost:6443

  echo ""
  echo "Kubernetes config downloaded and stored at $HOME/.kube/do-k8s"
}

function print_usage {
  echo "Useage instructions:"
  echo "  k8s_config.sh [command]"
  echo "    commands:"
  echo "      tunnel:      create a ssh tunnel to the k8s api"
  echo "      tunnel-stop: stop the tunnel to the k8s api"
  echo "      get-config:  fetch the kubernetes config"
  echo ""
  echo "NOTE: IP addresses and the path to the private key will be picked up from the terraform output"
  echo ""
  exit 2
}

if [ $# -eq 0 ]; then
  print_usage
fi

command=$1

case $command in
  tunnel)
    tunnel_k8s_api
    ;;
  tunnel-stop)
    tunnel_k8s_stop
    ;;
  get-config)
    get_k8s_config
    ;;
esac

export KUBECONFIG=$HOME/.kube/do-k8s
