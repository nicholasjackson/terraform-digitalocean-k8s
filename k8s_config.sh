#!/bin/bash
function tunnel_k8s_api {
  ssh -i $1 -f root@$(terraform output k8s_master_public_ip) -L 6443:$(terraform output web_ip):6443 -N

  echo "Started SSH tunnel to K8s master, the API is now available at https://kubernetes:6443"
}

function get_k8s_config {
  mkdir -p $HOME/.kube 
  scp -i $1 root@$(terraform output k8s_master_public_ip):/etc/kubernetes/admin.conf $HOME/.kube/do-k8s
  KUBECONFIG=$HOME/.kube/do-k8s kubectl config set-cluster kubernetes --server=https://kubernetes:6443

  echo "Kubernetes config downloaded and stored at $HOME/.kube/do-k8s"
}

function print_usage {
  echo "Useage instructions:"
  echo "  k8s_config.sh [command] -i [path to ssh private key]"
  echo "    commands:"
  echo "      tunnel    : create a ssh tunnel to the k8s api"
  echo "      get-config: fetch the kubernetes config"
  echo ""
  exit 2
}

if [ $# -eq 0 ]; then
  print_usage
fi

command=$1
shift

ssh_key=""
while getopts "i:" OPTION
do
	case $OPTION in
    i)
      ssh_key=$OPTARG
      ;;
    \?)
      print_usage
      ;;
  esac
  shift
done

if [[ $ssh_key == "" ]]; then
  print_usage
fi

case $command in
  tunnel)
    tunnel_k8s_api $ssh_key
    ;;
  get-config)
    get_k8s_config $ssh_key
    ;;
esac

export KUBECONFIG=$HOME/.kube/do-k8s
