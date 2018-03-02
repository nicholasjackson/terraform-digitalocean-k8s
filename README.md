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

## SSH Tunnel to new machine
We can create an ssh tunnel to our newly created droplet using the following command this will allow us to access the `kubectl` locally

```
ssh -f root@$(terraform output web_ip) -L 6443:$(terraform output web_ip):6443 -N
```
