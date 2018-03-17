# Configure the DigitalOcean Provider
provider "digitalocean" {}

data "digitalocean_image" "k8s" {
  name = "${var.image_name}"
}

resource "random_string" "join_start" {
  upper   = false
  special = false
  length  = 6
}

resource "random_string" "join_end" {
  upper   = false
  special = false
  length  = 16
}

locals {
  join_token = "${coalesce("${var.k8s_token}", "${random_string.join_start.result}.${random_string.join_end.result}")}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "${var.namespace}-cluster-ssh-key"
  public_key = "${file("${var.ssh_public_key}")}"
}
