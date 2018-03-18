module "k8s_cluster" {
  source = "../"

  namespace = "my_k8s_cluster"

  ssh_public_key  = "~/.ssh/server_rsa.pub"
  ssh_private_key = "~/.ssh/server_rsa"

  image_name = "k8s-1.9.4-00-ubuntu-16-04-x64"

  k8s_version = "v1.9.4"
  k8s_workers = 2

  digitalocean_api_token = "${var.digitalocean_api_token}"
}

variable "digitalocean_api_token" {
  description = "API token for digital ocean, required by the K8s cloud controller"
}

output "k8s_master_public_ip" {
  value = "${module.k8s_cluster.master_public_ip}"
}

output "k8s_master_private_ip" {
  value = "${module.k8s_cluster.master_private_ip}"
}

output "k8s_workers_public_ip" {
  value = "${module.k8s_cluster.workers_public_ip}"
}

output "k8s_workers_private_ip" {
  value = "${module.k8s_cluster.workers_private_ip}"
}

output "k8s_private_key" {
  value = "${module.k8s_cluster.private_key}"
}

output "k8s_public_key" {
  value = "${module.k8s_cluster.public_key}"
}

output "k8s_join_token" {
  value = "${module.k8s_cluster.join_token}"
}
