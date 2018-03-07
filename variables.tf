variable "ssh_public_key" {
  description = "SSH public key to add to droplets"
  default     = "~/.ssh/id_rsa.pub"
}

variable "image_id" {
  description = "Digital Ocean Image ID"
  default     = "32387489"
}

variable "k8s_token" {
  description = "K8s token to use for joining clusters"
  default     = "b5aa6e.c74e8c9996726092"
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "v1.8.8"
}

variable "digitalocean_api_token" {
  description = "API token for digital ocean, required by the K8s cloud controller"
}
