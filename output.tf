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

output "k8s_private_key" {
  value = "${var.ssh_private_key}"
}

output "k8s_public_key" {
  value = "${var.ssh_public_key}"
}
