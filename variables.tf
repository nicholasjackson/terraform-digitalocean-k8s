variable "ssh_public_key" {
  description = "SSH public key to add to droplets"
  default     = "~/.ssh/server_rsa.pub"
}

variable "ssh_private_key" {
  description = "SSH public key to add to droplets"
  default     = "~/.ssh/server_rsa"
}

variable "image_name" {
  description = "Digital Ocean image name"
}

variable "k8s_token" {
  description = "K8s token to use for joining clusters, this should be generated uniquely for each cluster"
  default     = "b5aa6e.c74e8c9996726092"
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "v1.8.8"
}

variable "k8s_workers" {
  description = "Number of Kubernetes worker nodes"
  default     = 2
}

variable "digitalocean_api_token" {
  description = "API token for digital ocean, required by the K8s cloud controller"
}
