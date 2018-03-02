# Configure the DigitalOcean Provider
provider "digitalocean" {}

resource "digitalocean_ssh_key" "default" {
  name       = "K8s Cluster"
  public_key = "${file("${var.ssh_public_key}")}"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "k8s_master" {
  count = 1

  image              = "${var.image_id}"
  name               = "k8s-master"
  region             = "lon1"
  size               = "4gb"
  private_networking = true

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]

  # bring up the kube master on the master node
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
    }

    inline = [
      # init k8s and bind to private ip address
      "sudo kubeadm init --apiserver-advertise-address=${digitalocean_droplet.k8s_master.ipv4_address_private}",
    ]
  }
}

output "web_ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address}"
}
