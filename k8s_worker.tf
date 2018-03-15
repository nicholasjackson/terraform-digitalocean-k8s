resource "digitalocean_droplet" "k8s_worker" {
  count = "${var.k8s_workers}"

  image              = "${data.digitalocean_image.k8s.image}"
  name               = "k8s-worker-${count.index}"
  region             = "lon1"
  size               = "4gb"
  private_networking = true

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]

  # bring up the kube master on the master node
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      # init k8s and bind to private ip address
      "sudo kubeadm join --token=${var.k8s_token} --discovery-token-unsafe-skip-ca-verification ${digitalocean_droplet.k8s_master.ipv4_address_private}:6443",
    ]
  }
}
