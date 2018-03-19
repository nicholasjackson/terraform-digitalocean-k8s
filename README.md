# Kubernetes cluster on Digital Ocean

[![Open Source Helpers](https://www.codetriage.com/nicholasjackson/terraform-digitalocean-k8s/badges/users.svg)](https://www.codetriage.com/nicholasjackson/terraform-digitalocean-k8s)

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
* DigitalOcean cloud controller which automatically creates a DigitalOcean load balancer creation when a new service is defined
* Packer build with base software

## Usage:
To create a Kubernetes cluster create the base image with Packer as shown in the [example cluster](https://github.com/nicholasjackson/terraform-digitalocean-k8s/tree/master/examples)
, then add the following module to your Terraform config replacing the values for the inputs as required.

```hcl
module "k8s_cluster" {
  source = "nicholasjackson/k8s/digitalocean"

  namespace = "my_k8s_cluster"

  ssh_public_key  = "~/.ssh/server_rsa.pub"
  ssh_private_key = "~/.ssh/server_rsa"

  image_name = "k8s-1.9.4-00-ubuntu-16-04-x64"
  size       = "s-1vcpu-1gb"

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
| size | DigitalOcean droplet size, details of available droplets can be found in the docs https://developers.digitalocean.com/documentation/v2/#sizes Kubernetes |
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

[example cluster](https://github.com/nicholasjackson/terraform-digitalocean-k8s/tree/master/examples)

## Digital Ocean Droplet Sizes
The table below lists the currently available droplets, data obtained from the DigitalOcean API 19/03/2018.  NOTE: Kubernetes requires a minimum of 1024mb of ram to run.

| Slug          | Memory | Vcpus | Disk  | Transfer | Price monthly | Price hourly         | Regions                                                     | Available |
| ------------- | ------ | ----- | ----- | -------- | ------------- | -------------------- | ----------------------------------------------------------- | --------- |
| 512mb         | 512    | 1     | 20    | 1        | 5             | 0.007439999841153622 | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-1vcpu-1gb   | 1024   | 1     | 25    | 1        | 5             | 0.007439999841153622 | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| 1gb           | 1024   | 1     | 30    | 2        | 10            | 0.01487999968230724  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-1vcpu-2gb   | 2048   | 1     | 50    | 2        | 10            | 0.01487999968230724  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-1vcpu-3gb   | 3072   | 1     | 60    | 3        | 15            | 0.02232000045478344  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-2vcpu-2gb   | 2048   | 2     | 60    | 3        | 15            | 0.02232000045478344  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-3vcpu-1gb   | 1024   | 3     | 60    | 3        | 15            | 0.02232000045478344  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| 2gb           | 2048   | 2     | 40    | 3        | 20            | 0.02975999936461449  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-2vcpu-4gb   | 4096   | 2     | 80    | 4        | 20            | 0.02975999936461449  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| 4gb           | 4096   | 2     | 60    | 4        | 40            | 0.05951999872922897  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| c-2           | 4096   | 2     | 25    | 4        | 40            | 0.05999999865889549  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-4vcpu-8gb   | 8192   | 4     | 160   | 5        | 40            | 0.05951999872922897  | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| 8gb           | 8192   | 4     | 80    | 5        | 80            | 0.1190500035881996   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| c-4           | 8192   | 4     | 50    | 5        | 80            | 0.1190000027418137   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-6vcpu-16gb  | 16384  | 6     | 320   | 6        | 80            | 0.1190500035881996   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| 16gb          | 16384  | 8     | 160   | 6        | 160           | 0.2381000071763992   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| c-8           | 16384  | 8     | 100   | 6        | 160           | 0.2380000054836273   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-8vcpu-32gb  | 32768  | 8     | 640   | 7        | 160           | 0.2381000071763992   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| s-12vcpu-48gb | 49152  | 12    | 960   | 8        | 240           | 0.3571400046348572   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |
| 32gb          | 32768  | 12    | 320   | 7        | 320           | 0.4761900007724762   | ams2,ams3,blr1,fra1,lon1,nyc1,nyc2,nyc3,sfo1,sfo2,sgp1,tor1 | true      |


