output "master_public_ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address}"
}

output "master_private_ip" {
  value = "${digitalocean_droplet.k8s_master.ipv4_address_private}"
}

output "workers_public_ip" {
  value = "${digitalocean_droplet.k8s_worker.*.ipv4_address}"
}

output "workers_private_ip" {
  value = "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}"
}

output "private_key" {
  value = "${var.ssh_private_key}"
}

output "public_key" {
  value = "${var.ssh_public_key}"
}
