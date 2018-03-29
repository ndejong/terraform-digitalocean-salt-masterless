
# required variables - no defaults
# ============================================================================

variable "hostname" {
  description = "The hostname applied to this digitalocean-droplet."
}

variable "digitalocean_region" {
  description = "The digitalocean region-slug to start this digitalocean-droplet within."
}

variable "salt_local_state_tree" {
  description = "Salt local_state_tree path"
}

variable "salt_local_pillar_roots" {
  description = "Salt local_pillar_roots path"
}

# variables - with defined defaults
# ============================================================================

variable "permit_root_login" {
  description = "Permit root login after droplet has completed deployment - NB: the root bootstrap-sshkey remains in CLEARTEXT in the Terraform statefile, setting this parameter to '0' removes the bootstrap ssh-publickey and additionally sets PermitRootLogin to 'no' after the bootstrap process is complete."
  default = 0
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
  default = "ubuntu-17-10-x64"
}

variable "digitalocean_size" {
  description = "The size to use for this digitalocean-droplet."
  default = "1gb"
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
  description = "Volume0 to attach to this digitalocean-droplet in the format <mount-point>:<mount-device>:<volume-id>:<mount-fstype>"
  default = ""
}
