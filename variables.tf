# terraform-digitalocean-salt-masterless
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0


# required variables
# ============================================================================

variable "hostname" {
  description = "The hostname applied to this salt-masterless droplet."
}

variable "digitalocean_region" {
  description = "The DigitalOcean region-slug to start this salt-masterless within (nyc1, sgp1, lon1, nyc3, ams3, fra1, tor1, sfo2, blr1)"
}

variable "digitalocean_token" {
  description = "Your DigitalOcean API token used to issue cURL API calls directly to DigitalOcean to create the required image"
}

variable "salt_local_state_tree" {
  description = "Salt local_state_tree path"
}

variable "salt_local_pillar_roots" {
  description = "Salt local_pillar_roots path"
}

# variables - with defined defaults
# ============================================================================

variable "disable_root_login" {
  description = "Disable the root login after droplet has completed deployment - NB: the root bootstrap-sshkey remains in CLEARTEXT in the Terraform statefile, setting this parameter to '1' removes the bootstrap ssh-publickey from the remote system and sets PermitRootLogin to 'no' in the ssh-config after the bootstrap process is complete."
  default = 1
}

variable "disable_saltminion_service" {
  description = "The salt-minion service is by default installed and started as a service which in a salt-headless arrangement is not required, this option by default disables that service"
  default = 1
}

variable "salt_local_minion_config_file" {
  description = "Local salt minion config to be pushed to the remote system"

  #
  # Note: an "empty" pointer to /dev/null is made here to prevent Terraform throwing an error "file: open : no such file or directory"
  # when the user does not provide a (custom) minion.config file to be used at the remote system
  #

  default = "/dev/null"
}

variable "salt_remote_state_tree" {
  description = "Remote system remote_state_tree path"
  default = "/srv/salt"
}

variable "salt_remote_pillar_roots" {
  description = "Remote system remote_pillar_roots path"
  default = "/srv/pillar"
}

variable "salt_custom_state" {
  description = "Salt custom_state definition"
  default = ""
}

variable "salt_log_level" {
  description = "Salt logging level"
  default = "warning"
}

variable "digitalocean_image" {
  description = "The digitalocean image to use as the base for this digitalocean-droplet."
  default = "ubuntu-18-04-x64"    # tested and confirmed 2018-07-18
  # default = "ubuntu-17-10-x64"  # tested and confirmed 2018-03-29, 2018-07-18
  # default = "ubuntu-16-04-x64"  # tested and confirmed 2018-03-29, 2018-07-18
}

variable "digitalocean_size" {
  description = "The digitalocean droplet size to use for this digitalocean-droplet."

  #
  # reference:
  #   https://www.digitalocean.com/docs/release-notes/2018/droplet-bandwidth-billing/
  #
  # helpful cli tool to discover digitalocean droplet size values - use the "regions" argument:
  #   https://github.com/verbnetworks/digitalocean-api-query
  #

  default = "s-1vcpu-1gb"
}

variable "digitalocean_backups" {
  description = "Enable/disable backup functionality on this digitalocean-droplet."
  default = false
}

variable "digitalocean_monitoring" {
  description = "Enable/disable monitoring functionality on this digitalocean-droplet."
  default = true
}

variable "digitalocean_ipv6" {
  description = "Enable/disable getting a public IPv6 on this digitalocean-droplet."
  default = false
}

variable "digitalocean_private_networking" {
  description = "Enable/disable private-networking functionality on this digitalocean-droplet."
  default = false
}

# variables - optional
# ============================================================================
variable "digitalocean_volume0" {
  description = "Volume0 to attach to this digitalocean-droplet in the format <mount-point>:<mount-device>:<volume-id>:<mount-fstype> - review README for information on discovering the <volume-id> value."

  #
  # example value:
  #   digitalocean_volume0 = "/mnt:/dev/disk/by-id/scsi-0DO_Volume_example01:0010c05e-20ad-10e0-9007-00000c113408:ext4"
  #
  # helpful cli tool to discover the <volume-id> value - use the "volumes" argument:
  #   https://github.com/verbnetworks/digitalocean-api-query
  #

  default = ""
}
