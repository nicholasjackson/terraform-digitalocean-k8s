# Configure the DigitalOcean Provider
provider "digitalocean" {}

resource "digitalocean_ssh_key" "default" {
  name       = "K8s Cluster"
  public_key = "${file("${var.ssh_public_key}")}"
}

data "template_file" "k8s_api_secret" {
  template = "${file("./templates/digitalocean-api-secret.yml")}"

  vars {
    digitalocean_api_token = "${var.digitalocean_api_token}"
  }
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

  # copy the api secret to the master
  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
    }

    content     = "${data.template_file.k8s_api_secret.rendered}"
    destination = "/tmp/api-secret.yml"
  }

  provisioner "file" {
    connection {
      type = "ssh"
      user = "root"
    }

    content     = "${file("./templates/cloud-deployment-manager.yml")}"
    destination = "/tmp/cloud-deployment-manager.yml"
  }

  # bring up the kube master on the master node
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
    }

    inline = [
      # init k8s and bind to private ip address
      "sudo kubeadm init --kubernetes-version=${var.k8s_version} --token=${var.k8s_token} --apiserver-advertise-address=${digitalocean_droplet.k8s_master.ipv4_address_private}:6443",

      # Update kubelet startup to add config for cloud deployment manager
      "sudo sed -i 's#ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS#ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS --cloud-provider=external#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf",

      "sudo systemctl daemon-reload",
      "sudo systemctl restart kubelet.service",

      # Install Weave networking plugin
      "export KUBECONFIG=/etc/kubernetes/admin.conf",

      "kubectl apply -f \"https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')\"",

      # Add Digital Ocean cloud deployment manager
      "kubectl apply -f /tmp/api-secret.yml",

      "kubectl apply -f /tmp/cloud-deployment-manager.yml",
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

      # Update kubelet startup to add config for cloud deployment manager
      "sudo sed -i 's#ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS#ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_AUTHZ_ARGS $KUBELET_CADVISOR_ARGS $KUBELET_CERTIFICATE_ARGS $KUBELET_EXTRA_ARGS --cloud-provider=external#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf",

      "sudo systemctl daemon-reload",
      "sudo systemctl restart kubelet.service",
    ]
  }
}

output "k8s_master_public_ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address}"
}

output "k8s_master_private_ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
}

output "k8s_workers_public_ip" {
  value = "${digitalocean_droplet.k8s_worker.*.ipv4_address}"
}

output "k8s_workers_private_ip" {
  value = "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}"
}
