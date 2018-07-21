# Terraform + Digital Ocean + Salt (Masterless)

Terraform module to create a Digital Ocean Droplet using the Terraform Salt Masterless Provisioner, including a tool 
`salt-push` which provides an easy way to push a new saltstack without needing to do a full system tear-down.
 * [Saltstack](https://docs.saltstack.com/en/latest/)
 * [Terraform Salt-Masterless Provisioner](https://www.terraform.io/docs/provisioners/salt-masterless.html)
 * [Digital Ocean](https://www.digitalocean.com/)


## Usage
This module allows you to establish a Droplet on Digital Ocean with SaltStack in masterless mode easily
as shown in the example below:-

```hcl
variable "do_token" {}    # set via environment value `TF_VAR_do_token`

provider "digitalocean" {
  token = "${var.do_token}"
}

module "terraform-digitalocean-salt-masterless" {
  source  = "verbnetworks/salt-masterless/digitalocean"

  # required variables
  # ===
  hostname = "node08"
  digitalocean_region = "sgp1"
  salt_local_state_tree = "/local/path/to/node08/states"
  salt_local_pillar_roots = "/local/path/to/node08/pillars"

  # optional variables
  # ===
  # digitalocean_volume0 = "<mount-point>:<mount-device>:<volume-id>:<mount-fstype>"
  # 
  # Example:-
  # digitalocean_volume0 = "/mnt:/dev/disk/by-id/scsi-0DO_Volume_example01:0010c05e-20ad-10e0-9007-00000c113408:ext4"
}

# optional outputs
output "hostname" { value = "${module.terraform-digitalocean-salt-masterless.hostname}" }
output "region" { value = "${module.terraform-digitalocean-salt-masterless.region}" }
output "ipv4_address" { value = "${module.terraform-digitalocean-salt-masterless.ipv4_address}" }
output "volume0" { value = "${module.terraform-digitalocean-salt-masterless.volume0}" }
output "salt_local_minion_config_file" { value = "${module.terraform-digitalocean-salt-masterless.salt_local_minion_config_file}" }
output "salt_local_state_tree" { value = "${module.terraform-digitalocean-salt-masterless.salt_local_state_tree}" }
output "salt_local_pillar_roots" { value = "${module.terraform-digitalocean-salt-masterless.salt_local_pillar_roots}" }
output "salt_remote_state_tree" { value = "${module.terraform-digitalocean-salt-masterless.salt_remote_state_tree}" }
output "salt_remote_pillar_roots" { value = "${module.terraform-digitalocean-salt-masterless.salt_remote_pillar_roots}" }
```

#### Note on the `digitalocean_volume0` attribute
It is optionally possible to mount a pre-existing volume to your Droplet by providing the mount details in the 
following format `<mount-point>:<mount-device>:<volume-id>:<mount-fstype>`

Obtaining the `<volume-id>` value is not straight-forward through the Digital Ocean web admin user interface and 
requires that you call their API to obtain it.  You can consider using the [digitalocean-api-query](https://github.com/verbnetworks/digitalocean-api-query)
cli tool with the "volumes" argument to discover this value.

```text
$ digitalocean-api-query volumes | jq .volumes
[
  {
    "id": "0010c05e-20ad-10e0-9007-00000c113408",
    "name": "example01",
    "created_at": "2018-03-07T02:12:46Z",
...
```

## The `salt-push` tool
An additional `salt-push` tool is provided to easily push new salt-states and salt-pillars and invoke a remote 
salt-call.  The `salt-push` tool achieves this by inspecting the (local) `tfstate` file for information about the remote 
system address, local and remote paths - this allows you to very easily push and update the remote saltstack with
a one-line command.

```bash
$ ./tools/salt-push /path/to/terraform.tfstate

salt-push
===
local_minion_config_file: /dev/null
local_states_path: /path/to/salt/states
local_pillars_path: /path/to/salt/pillars
remote_states_path: /srv/salt
remote_pillars_path: /srv/pillar
remote_address: x.x.x.x
connect to x.x.x.x on tcp:22 - Okay!
temp setting remote salt-config ownership to allow remote salt-config changes...
rsyncd remote_states_path - Okay!
rsyncd remote_pillars_path - Okay!
setting remote salt-config ownership back to root...
invoking salt-call over ssh...

...

Summary for local
------------
Succeeded: 4
Failed:    0
------------
Total states run:     4
Total run time:  70.244 ms
```

## History
This module was originally published via `https://github.com/ndejong/terraform-digitalocean-salt-masterless` 
and was subsequently moved which required it to be removed and re-added to the Terraform Module repository.


****


## Input Variables - Required

### hostname
The hostname applied to this strelaysrv-node droplet.

### digitalocean_region
The DigitalOcean region-slug to start this strelaysrv-node within (nyc1, sgp1, lon1, nyc3, ams3, fra1, tor1, sfo2, blr1)

### digitalocean_token
Your DigitalOcean API token used to issue cURL API calls directly to DigitalOcean to create the required image

### salt_local_state_tree
Local path to the SaltStack state-tree to apply to the remote system

### salt_local_pillar_roots
Local path to the SaltStack pillar-roots to apply to the remote system


## Input Variables - Optional

### disable_root_login
Disable the root login after droplet has completed deployment - NB: the root bootstrap-sshkey remains in CLEARTEXT in the Terraform statefile, setting this parameter to '1' removes the bootstrap ssh-publickey from the remote system and sets PermitRootLogin to 'no' in the ssh-config after the bootstrap process is complete.
 - default = 1

### disable_saltminion_service
The salt-minion service is by default installed and started as a service which in a salt-headless arrangement is not required, this option by default disables that service.
 - default = 1

### salt_local_minion_config_file
Local salt minion config to be pushed to the remote system
 - default = ""

### salt_remote_state_tree
Remote system remote_state_tree path
 - default = "/srv/salt"

### salt_remote_pillar_roots
Remote system remote_pillar_roots path
 - default = "/srv/pillar"

### salt_custom_state
Salt custom_state definition
 - default = ""

### salt_log_level
Salt logging level
 - default = "warning"

### digitalocean_image
The digitalocean image to use as the base for this digitalocean-droplet
 - default = "ubuntu-18-04-x64"

### digitalocean_size
The size to use for this digitalocean-droplet.
  default = "s-1vcpu-1gb"

### digitalocean_backups
Enable/disable backup functionality on this digitalocean-droplet.
 - default = false

### digitalocean_monitoring
Enable/disable monitoring functionality on this digitalocean-droplet.
 - default = true

### digitalocean_ipv6
Enable/disable getting a public IPv6 on this digitalocean-droplet.
 - default = false

### digitalocean_private_networking
Enable/disable private-networking functionality on this digitalocean-droplet.
 - default = false

### digitalocean_volume0
Volume0 to attach to this digitalocean-droplet in the format `<mount-point>:<mount-device>:<volume-id>:<mount-fstype>` - review README for information on discovering the <volume-id> value.
 - default = ""


## Outputs

### hostname
The hostname applied to this digitalocean-droplet.

### region
The digitalocean region-slug this digitalocean-droplet is running in.

### ipv4_address
The public IPv4 address of this digitalocean-droplet.

### volume0
The volume attach to this digitalocean-droplet in the format `<mount-point>:<mount-device>:<volume-id>:<mount-fstype>`

### salt_local_minion_config_file
The local SaltStack minion config file sent to the remote host

### salt_local_state_tree
The local SaltStack state-tree path sent to the remote host

### salt_local_pillar_roots
The local SaltStack pillar-root path sent to the remote host

### salt_remote_state_tree
The remote-system path to the SaltStack state-tree path

### salt_remote_pillar_roots
The remote-system path to the SaltStack pillar-roots path

****

## Authors
Module managed by [Verb Networks](https://github.com/verbnetworks)

## License
Apache 2 Licensed. See LICENSE for full details.
