# Configure the DigitalOcean Provider
provider "digitalocean" {}

data "digitalocean_image" "k8s" {
  name = "${var.image_name}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "K8s Cluster"
  public_key = "${file("${var.ssh_public_key}")}"
}

variable "workspace" {
  description = "Allow the override of the workspace, for example if running on TFE workspace is not present"
  default     = ""
}

# Set workspace value to a local variable,
# config will depend on the variable not directly depend on the workspace.
# This is useful due to the differences in TFE and OSS, this approach will not require
# replacement of hard coded workspace values when migrating a config to TFE.
# https://www.terraform.io/docs/configuration/locals.html
locals {
  workspace = "${coalesce("${var.workspace}","${terraform.workspace}")}"
}

# Local variables can be referenced with the ${local.name} interpolation syntax
output "workspace" {
  value = "${local.workspace}"
}
