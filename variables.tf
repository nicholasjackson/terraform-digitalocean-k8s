variable "ssh_public_key" {
  description = "SSH public key to add to droplets"
  default     = "~/.ssh/id_rsa.pub"
}

variable "image_id" {
  description = "Digital Ocean Image ID"
  default     = "32247219"
}
