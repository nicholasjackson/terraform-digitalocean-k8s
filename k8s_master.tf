# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "k8s_master" {
  count = 1

  image              = "${data.digitalocean_image.k8s.image}"
  name               = "k8s-master-${count.index}"
  region             = "${var.region}"
  size               = "${var.size}"
  private_networking = true

  ssh_keys = ["${digitalocean_ssh_key.default.fingerprint}"]
}

# We need to use a null_resource provisioner instead of a inline provisioner because of cyclical dependencies in 
# the init template
resource "null_resource" "k8s_master" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
  }

  # copy the api secret to the master
  provisioner "file" {
    connection {
      host        = "${digitalocean_droplet.k8s_master.ipv4_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.cloud_deployment_manager.rendered}"
    destination = "/tmp/cloud-deployment-manager.yml"
  }

  provisioner "file" {
    connection {
      host        = "${digitalocean_droplet.k8s_master.ipv4_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.k8s_config.rendered}"
    destination = "/tmp/kube-config.yml"
  }

  provisioner "file" {
    connection {
      host        = "${digitalocean_droplet.k8s_master.ipv4_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    content     = "${data.template_file.k8s_init.rendered}"
    destination = "/tmp/init.sh"
  }

  provisioner "remote-exec" {
    connection {
      host        = "${digitalocean_droplet.k8s_master.ipv4_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key}")}"
    }

    inline = [
      "chmod +x /tmp/init.sh",
      "/tmp/init.sh",
    ]
  }
}

# Add the digital ocean API key to the cloud deployment manager provisioning script
data "template_file" "cloud_deployment_manager" {
  template = "${file("${path.module}/templates/cloud-deployment-manager.yml")}"

  vars {
    digitalocean_api_token = "${var.digitalocean_api_token}"
  }
}

# The init script needs to be modified to add the dynamic elements such as the kubernettes version
# and the ip address to advertise the API to
data "template_file" "k8s_init" {
  template = "${file("${path.module}/templates/k8s-init.sh")}"

  vars {
    node_ip = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
  }
}

data "template_file" "k8s_config" {
  template = "${file("${path.module}/templates/k8s-config.yml")}"

  vars {
    version           = "${var.k8s_version}"
    token             = "${var.k8s_token}"
    advertise_address = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
  }
}
