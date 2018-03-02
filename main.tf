# Configure the DigitalOcean Provider
provider "digitalocean" {}

resource "digitalocean_ssh_key" "default" {
  name       = "K8s Cluster"
  public_key = "${file("${var.ssh_public_key}")}"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "k8s" {
  count = 1

  image  = "${var.image_id}"
  name   = "k8s-1"
  region = "lon1"
  size   = "4gb"

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

output "web_ip" {
  value = "${digitalocean_droplet.k8s.ipv4_address}"
}
