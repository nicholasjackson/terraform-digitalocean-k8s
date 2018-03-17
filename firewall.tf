/*
      source_addresses = [
        "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}",
        "${digitalocean_droplet.k8s_worker.*.ipv4_address}",
        "${digitalocean_droplet.k8s_master.ipv4_address_private}",
        "${digitalocean_droplet.k8s_master.ipv4_address}",
      ]
*/

resource "digitalocean_firewall" "k8s" {
  name = "only-22-80-and-443"

  droplet_ids = ["${digitalocean_droplet.k8s_master.id}"]

  inbound_rule = [
    {
      # Allow all internal access for cluster members
      protocol   = "tcp"
      port_range = "1-65535"

      source_addresses = [
        "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}",
        "${digitalocean_droplet.k8s_worker.*.ipv4_address}",
        "${digitalocean_droplet.k8s_master.ipv4_address_private}",
        "${digitalocean_droplet.k8s_master.ipv4_address}",
      ]
    },
    {
      protocol   = "udp"
      port_range = "1-65535"

      source_addresses = [
        "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}",
        "${digitalocean_droplet.k8s_worker.*.ipv4_address}",
        "${digitalocean_droplet.k8s_master.ipv4_address_private}",
        "${digitalocean_droplet.k8s_master.ipv4_address}",
      ]
    },
    {
      protocol   = "icmp"
      port_range = "1-65535"

      source_addresses = [
        "${digitalocean_droplet.k8s_worker.*.ipv4_address_private}",
        "${digitalocean_droplet.k8s_worker.*.ipv4_address}",
        "${digitalocean_droplet.k8s_master.ipv4_address_private}",
        "${digitalocean_droplet.k8s_master.ipv4_address}",
      ]
    },
    {
      # Allow SSH access from all hosts
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}
