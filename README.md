# Building a K8s cluster with Terraform and Packer on Digital Ocean

## Step 1
Install HashiCorp Packer and Terraform

## Configure your Digital Ocean API key environment variables

```bash
export DIGITALOCEAN_TOKEN=xxxxxxx
export DIGITALOCEAN_API_TOKEN=xxxxx
```

## Build a K8s base image in Digital Ocean

```bash
$ cd packer
$ packer build k8s.json
#...
==> digitalocean: Waiting for snapshot to complete...
==> digitalocean: Destroying droplet...
==> digitalocean: Deleting temporary ssh key...
Build 'digitalocean' finished.

==> Builds finished. The artifacts of successful builds are:
--> digitalocean: A snapshot was created: 'packer-1520008641' (ID: 32247219) in regions ''
```

## Provision resources in Digital Ocean based on our built image

```bash
$ terraform apply -var image_id=your_image_id
#...
digitalocean_droplet.k8s: Still creating... (20s elapsed)
digitalocean_droplet.k8s: Still creating... (30s elapsed)
digitalocean_droplet.k8s: Still creating... (40s elapsed)
digitalocean_droplet.k8s: Creation complete after 48s (ID: 84335638)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

web_ip = 159.65.50.173
```

## Download the Kubernettes config

```bash
mkdir -p $HOME/.kube 
scp root@$(terraform output web_ip):/etc/kubernetes/admin.conf $HOME/.kube/do-k8s
```

## Change server in kubectl config
Inside the kube config the server address will be set to the local ip for the node in order to access it we need to add a local hosts entry for the domain `kubernetes` and then
update kube config


Append the following to /etc/hosts
```
127.0.0.1  kubernetes
```

Update kube config
```
KUBECONFIG=$HOME/.kube/do-k8s kubectl config set-cluster kubernetes --server=https://kubernetes:6443
```

## SSH Tunnel to new machine
We can create an ssh tunnel to our newly created droplet using the following command this will allow us to access the `kubectl` locally

```
$ ssh -f root@$(terraform output web_ip) -L 6443:$(terraform output web_ip):6443 -N
$ KUBECONFIG=$HOME/.kube/do-k8s kubectl get nodes
NAME      STATUS     ROLES     AGE       VERSION
k8s-1     NotReady   master    51s       v1.9.3
```

## Next time
* Why we can not run init as part of the image
* Init adding kubernetes to /etc/hosts
* Update kube config `kubectl config set-cluster kubernetes --server=https://kubernetes:6443`
* Add networking
* Bind to local ip networking
