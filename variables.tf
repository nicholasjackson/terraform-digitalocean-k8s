variable "ssh_public_key" {
  description = "SSH public key to add to droplets"
  default     = "~/.ssh/id_rsa.pub"
}

variable "image_id" {
  description = "Digital Ocean Image ID"
  default     = "32247739"
}

variable "k8s_token" {
  description = "K8s token to use for joining clusters"
  default     = "b5aa6e.c74e8c9996726092"
}
