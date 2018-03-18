# Kubernetes cluster on Digital Ocean
Terraform module which creates a basic Kubernetes cluster on DigitalOcean

Supports:
* Kubernetes v1.8.8
* Kubernetes v1.9.4

## Features:
This module creates a simple Kubernetes cluster on DigitalOcean with the following features:

* Single Kubernetes master
* Configurable number of Kubernetes worker nodes
* Firewall configured to deny external access other than port 22 by default
* DigitalOcean private network
* DigitalOcean cloud controller allowing external load balancer creation when a new service is defined
* Packer build with base software

## Usage:
To create a Kubernetes cluster create the base image with Packer as shown in the [example cluster](./examples/README.md)
, then add the following module to your Terraform config replacing the values for the inputs as required.

```hcl
module "k8s_cluster" {
  source = "nicholasjackson/k8s/digitalocean"

  namespace = "my_k8s_cluster"

  ssh_public_key  = "~/.ssh/server_rsa.pub"
  ssh_private_key = "~/.ssh/server_rsa"

  image_name = "k8s-1.9.4-00-ubuntu-16-04-x64"

  k8s_version = "v1.9.4"
  k8s_workers = 2

  digitalocean_api_token = "${var.digitalocean_api_token}"
}

variable "digitalocean_api_token" {
  description = "API token for digital ocean, required by the K8s cloud controller"
}
```

## Inputs
The module defines the following inputs:

| name | description |
| ---- | ----------- |
| namespace | The namespace for the application |
| region | DigitalOcean region in which to create the cluster |
| size | DigitalOcean droplet size |
| ssh_public_key | Path to the SSH public key to add to the nodes |
| ssh_private_key | Path of the SSH private key used for provisioning |
| image_name | Digital ocean snapshot used as a base image |
| k8s_token | Optional token to be used for nodes to join the cluster, if ommited a token will be generated |
| k8s_version | Kubernetes version, default v1.9.4 |
| k8s_workers | Number of workers to create, default 2 |
| digitalocean_api_token | DigitalOcean API token, required to provision cloud load balancers |

## Outputs
The module defines the following outputs:

| name | description |
| ---- | ----------- |
| master_public_ip | Public IP address of the K8s master |
| master_private_ip | Private IP of the K8s master |
| workers_public_ip | List of Public IP addresses for the K8s workers |
| workers_private_ip | List of Private IP addresses for the K8s workers |
| private_key | Path to the SSH private key used for provisioning the nodes |
| public_key | Path to the SSH public key provisioned to the nodes |
| join_token | Join token used when creating the cluster, join tokens have a life span of 24hrs |

## Example
For more detailed example on useage, including instructions on creating a base image with Packer, and how to access the cluster using `kubectl` please see the README in the examples folder.

[example cluster](./examples/README.md)
