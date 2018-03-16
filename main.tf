# Configure the DigitalOcean Provider
provider "digitalocean" {}

data "digitalocean_image" "k8s" {
  name = "${var.image_name}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "${var.namespace}-cluster-ssh-key"
  public_key = "${file("${var.ssh_public_key}")}"
}
