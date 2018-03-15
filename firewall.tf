resource "digitalocean_firewall" "k8s" {
  name = "only-22-80-and-443"

  droplet_ids = ["${digitalocean_droplet.k8s_master.id}"]

  inbound_rule = [
    {
      # Internal access to K8s APIs for workers
      protocol         = "tcp"
      port_range       = "1-65535"
      source_addresses = ["10.0.0.0/8", "::/0"]
    },
    {
      protocol         = "udp"
      port_range       = "1-65535"
      source_addresses = ["10.0.0.0/8", "::/0"]
    },
    {
      protocol         = "icmp"
      port_range       = "1-65535"
      source_addresses = ["10.0.0.0/8", "::/0"]
    },
    {
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
