# Configure the DigitalOcean Provider
provider "digitalocean" {}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "web" {
  count = 1

  image  = "32050692"
  name   = "web-1"
  region = "lon1"
  size   = "512mb"

  ssh_keys = ["89:15:fd:02:04:44:73:a9:f7:fc:08:03:d0:ab:22:d4"]
}

output "web_ip" {
  value = "${digitalocean_droplet.web.ipv4_address}"
}
