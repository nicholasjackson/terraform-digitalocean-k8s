variable "namespace" {
  description = "Namespace for the application"
  default     = "k8s_cluster"
}

variable "region" {
  description = "Digital Ocean region in which to create the cluster"
  default     = "lon1"
}

variable "size" {
  description = "Digital Ocean droplet size, default is 2core with 2gb of ram, $15 per month per droplet"
  default     = "s-2vcpu-2gb"
}

variable "ssh_public_key" {
  description = "path of SSH public key to add to droplets"
}

variable "ssh_private_key" {
  description = "path of SSH private key"
}

variable "image_name" {
  description = "Digital Ocean image name"
}

variable "k8s_token" {
  description = "K8s token to use for joining clusters, this should be generated uniquely for each cluster, if this is not provided, Terraform will generate a token automatically"
  default     = ""
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "v1.9.4"
}

variable "k8s_workers" {
  description = "Number of Kubernetes worker nodes"
  default     = 2
}

variable "digitalocean_api_token" {
  description = "API token for digital ocean, required by the K8s cloud controller"
}
