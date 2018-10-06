# terraform-digitalocean-salt-masterless
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

# outputs
# ============================================================================

output "hostname" {
  description = "The hostname applied to this digitalocean-droplet."
  value = "${var.hostname}"
}

output "region" {
  description = "The digitalocean region-slug this digitalocean-droplet is running in."
  value = "${var.digitalocean_region}"
}

output "ipv4_address" {
  description = "The public IPv4 address of this digitalocean-droplet."
  value = "${digitalocean_droplet.droplet.ipv4_address}"
}

//
// you will require the latest Digital Ocean provider to access these attributes:-
//  - ipv4_address_private
//  - ipv6_address
//  - ipv6_address_private
//
// you may need to perform a `terraform init -upgrade` to get the latest Digital Ocean provider
//

output "ipv4_address_private" {
  description = "The private IPv4 address of this digitalocean-droplet."
  value = "${digitalocean_droplet.droplet.ipv4_address_private}"
}

output "ipv6_address" {
  description = "The public IPv6 address of this digitalocean-droplet."
  value = "${digitalocean_droplet.droplet.ipv6_address}"
}

output "ipv6_address_private" {
  description = "The private IPv6 address of this digitalocean-droplet."
  value = "${digitalocean_droplet.droplet.ipv6_address_private}"
}

output "volume0" {
  description = "The volume attach to this digitalocean-droplet in the format <mount-point>:<mount-device>:<volume-id>:<mount-fstype>"
  value = "${var.digitalocean_volume0}"
}

output "terraform_bootstrap_sshkey" {
  description = "The terraform-bootstrap-sshkey that was used to bootstrap this droplet."
  value = "terraform-bootstrap-sshkey-${random_string.random-chars.result}"
}

output "salt_local_minion_config_file" {
  description = ""
  value = "${var.salt_local_minion_config_file}"
}

output "salt_local_state_tree" {
  description = ""
  value = "${var.salt_local_state_tree}"
}

output "salt_local_pillar_roots" {
  description = ""
  value = "${var.salt_local_pillar_roots}"
}

output "salt_remote_state_tree" {
  description = ""
  value = "${var.salt_remote_state_tree}"
}

output "salt_remote_pillar_roots" {
  description = ""
  value = "${var.salt_remote_pillar_roots}"
}
