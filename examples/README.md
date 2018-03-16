# Building a K8s cluster with Terraform and Packer on Digital Ocean

## Step 1
Install HashiCorp Packer and Terraform: https://releases.hashicorp.com


## Configure your Digital Ocean API key environment variables

```bash
export DIGITALOCEAN_TOKEN=xxxxxxx
export DIGITALOCEAN_API_TOKEN=${DIGITALOCEAN_TOKEN}
export TF_VAR_digitalocean_api_token=${DIGITALOCEAN_TOKEN}
```

## Build a K8s base image in Digital Ocean
Before provisioning the infrastructure we need to build a base image which has Kubernetes and Docker installed.  We will use Packer for this, this only needs to be done once and the image stored in your digital ocean account.

```bash
$ cd packer
$ packer build k8s.json
#...
==> digitalocean: Waiting for snapshot to complete...
==> digitalocean: Destroying droplet...
==> digitalocean: Deleting temporary ssh key...
Build 'digitalocean' finished.

==> Builds finished. The artifacts of successful builds are:
--> digitalocean: A snapshot was created: 'k8s-1.8.8-00-ubuntu-16-04-x64' (ID: 32247219) in regions ''
```

## Provision resources in Digital Ocean based on our built image

First modify the example `main.tf` to change the values such as `image_name` and `ssh_public_key` to your values

```ruby
module "k8s_cluster" {
  source = "../"

  namespace = "my_k8s_cluster"

  ssh_public_key  = "path to your ssh public key"
  ssh_private_key = "path to your ssh private key"

  image_name = "name of your image built with packer"

  k8s_token   = "b5aa6e.c74e8c9996726092"
  k8s_workers = 2

  digitalocean_api_token = "${var.digitalocean_api_token}"
}
```

```bash
$ terraform init
#...
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```bash
$ terraform apply
#...
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

k8s_master_private_ip = 10.131.66.91
k8s_master_public_ip = 167.99.83.49
k8s_private_key = ~/.ssh/server_rsa
k8s_public_key = ~/.ssh/server_rsa.pub
k8s_workers_private_ip = [
    10.131.66.87,
    10.131.66.89
]
k8s_workers_public_ip = [
    167.99.83.47,
    167.99.83.48
]
workspace = prod
```

## Download the Kubernettes config

```bash
$ ./k8s_config.sh get-config
The authenticity of host '167.99.83.49 (167.99.83.49)' can't be established.
ECDSA key fingerprint is SHA256:eR+u/fSMzYwXrOETrYp27kCAdeNvAwZhjbF7kHT1IeY.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '167.99.83.49' (ECDSA) to the list of known hosts.
admin.conf                                                                                                                100% 5452   232.2KB/s   00:00
Cluster "kubernetes" set.

Kubernetes config downloaded and stored at /Users/nicj/.kube/do-k8s
```

## Add entry to etc hosts
To use an ssh tunnel with your K8s config you need to add the following entry to etc/hosts, this is because the SAN for the 
kubernetes TLS certificates does not contain `localhost`

Append the following to /etc/hosts

```bash
127.0.0.1  kubernetes
```

## SSH Tunnel to the k8s master
We can create an ssh tunnel to our newly created droplet using the following command this will allow us to use `kubectl` locally

```bash
$ ./k8s_config.sh tunnel

Started SSH tunnel to K8s master, the API is now available at https://kubernetes:6443
```

## Test kubectl has been set up correctly

```bash
$ KUBECONFIG=$HOME/.kube/do-k8s kubectl get nodes
NAME      STATUS     ROLES     AGE       VERSION
k8s-master-0   Ready     master    4m        v1.8.8
k8s-worker-0   Ready     <none>    4m        v1.8.8
k8s-worker-1   Ready     <none>    4m        v1.8.8
```

## Run a simple service

```bash
$ kubectl apply -f http-nginx.yml
service "http-lb" created
deployment "nginx-example" created

$ kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
http-lb      LoadBalancer   10.96.242.203   <pending>     80:30626/TCP   18s
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP        5m
```

## Clean up
Don't forget to clean up after yourself, running resources in the cloud is not free

1. First stop the running service, the Loadbalancer that K8s creates will not be destroyed by Terraform as Terraform did not create it.

```bash
$ kubectl delete -f http-nginx.yml
service "http-lb" deleted
deployment "nginx-example" deleted

$ kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   6m
```

2. Stop the ssh tunnel

```bash
$ ./k8s_config.sh tunnel-stop

Stopped ssh tunnel
```

3. Destroy the cluster

```bash
$ terraform destroy
#...
digitalocean_ssh_key.default: Destroying... (ID: 19206575)
digitalocean_ssh_key.default: Destruction complete after 0s

Destroy complete! Resources: 8 destroyed.
```
