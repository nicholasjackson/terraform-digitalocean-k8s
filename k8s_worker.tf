resource "digitalocean_droplet" "k8s_worker" {
  count = "${var.k8s_workers}"

  image              = "${data.digitalocean_image.k8s.image}"
  name               = "k8s-worker-${count.index}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

resource null_resource "k8s_worker" {
  count = "${var.k8s_workers}"

  # Wait for the workers to come up and for the master to finish provisioning
  triggers {
    cluster_ids = "${join(",", digitalocean_droplet.k8s_worker.*.ipv4_address_private)},${null_resource.k8s_master.id}"
  }

  provisioner "file" {
    connection {
      host        = "${element(digitalocean_droplet.k8s_worker.*.ipv4_address, count.index)}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${element(data.template_file.k8s_config_worker.*.rendered, count.index)}"
    destination = "/tmp/k8s-join.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = "${element(digitalocean_droplet.k8s_worker.*.ipv4_address, count.index)}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      "chmod +x /tmp/k8s-join.sh",
      "/tmp/k8s-join.sh",
    ]
  }
}

data "template_file" "k8s_config_worker" {
  count = "${var.k8s_workers}"

  template = "${file("${path.module}/templates/k8s-join.sh")}"

  vars {
    token     = "${local.join_token}"
    node_ip   = "${element(digitalocean_droplet.k8s_worker.*.ipv4_address_private, count.index)}"
    master_ip = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
  }
}
