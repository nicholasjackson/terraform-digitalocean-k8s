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
      "sudo kubeadm init --token=${var.k8s_token} --apiserver-advertise-address=${digitalocean_droplet.k8s_master.ipv4_address_private}",

      "kubectl get pods --all-namespaces",
    ]
  }
}

resource "digitalocean_droplet" "k8s_worker" {
  count = 2

  image              = "${var.image_id}"
  name               = "k8s-worker-${count.index}"
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
      "sudo kubeadm join --token=${var.k8s_token} --discovery-token-unsafe-skip-ca-verification ${digitalocean_droplet.k8s_master.ipv4_address_private}:6443",
    ]
  }
}

output "web_ip_k8s_master" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address}"
}

output "web_ip_k8s_master_privage" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
}

output "web_ip_k8s_workers" {
  value = "${digitalocean_droplet.k8s_worker.*.ipv4_address}"
}

output "web_ip_k8s_workers_private" {
  value = "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}"
}
