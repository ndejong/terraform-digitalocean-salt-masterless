# Terraform + Digital Ocean + Salt (Masterless)

Terraform module to create a Digital Ocean Droplet using the Terraform Salt Masterless Provisioner.
 * [saltstack](https://docs.saltstack.com/en/latest/)
 * [terraform salt-masterless](https://www.terraform.io/docs/provisioners/salt-masterless.html)
 * [digital ocean](https://www.digitalocean.com/)


## Usage
This module allows you to establish a Droplet on Digital Ocean with SaltStack in masterless mode easily
as shown in the example below:-

```hcl
module "droplet-saltstack-example" {
  source  = "ndejong/salt-masterless/digitalocean"
  hostname = "node0-sfo2-digitalocean"
  digitalocean_region = "sfo2"
  salt_local_state_tree = "/path/to/salt/states"
  salt_local_pillar_roots = "/path/to/salt/pillars"
}
```

Additionally, the `salt-pusher` tool is provided to easily push new salt-states and salt-pillars and invoke 
a salt-call, as shown:-

```bash
./tools/salt-pusher /path/to/terraform.tfstate

salt-pusher
===========
local_states_path: /path/to/salt/states
local_pillars_path: /path/to/salt/pillars
remote_states_path: /opt/salt/states
remote_pillars_path: /opt/salt/pillars
remote_address: x.x.x.x
connect to x.x.x.x on tcp:22 - Okay!
setting remote file ownership...
rsyncd remote_states_path - Okay!
rsyncd remote_pillars_path - Okay!
calling salt-call over ssh...

```

## Input Variables - Required

### hostname
The hostname applied to this digitalocean-droplet

### digitalocean_region
The digitalocean region-slug to start this digitalocean-droplet within

### salt_local_state_tree
Salt local_state_tree path

### salt_local_pillar_roots
Salt local_pillar_roots path


## Input Variables - Optional

### permit_root_login
Permit root login after droplet has completed deployment - NB: the root bootstrap-sshkey remains in CLEARTEXT in the Terraform statefile, setting this parameter to '0' removes the bootstrap ssh-publickey and additionally sets PermitRootLogin to 'no' after the bootstrap process is complete
 - Default: 0

## salt_local_minion_config_file
Local salt minion config to be pushed to the remote system
 - Default: ""

### salt_remote_state_tree
Remote system remote_state_tree path
 - Default: "/srv/salt"

### salt_remote_pillar_roots
Remote system remote_pillar_roots path
 - Default: "/srv/pillar"

### salt_custom_state
Salt custom_state definition
 - Default: ""

### salt_log_level
Salt logging level
 - Default: "warning"

### digitalocean_image
The digitalocean image to use as the base for this digitalocean-droplet
 - Default: "ubuntu-17-10-x64"

### digitalocean_size
The size to use for this digitalocean-droplet.
 - Default: "1gb"

### digitalocean_backups
Enable/disable backup functionality on this digitalocean-droplet.
 - Default: false

### digitalocean_monitoring
Enable/disable monitoring functionality on this digitalocean-droplet.
 - Default: true

### digitalocean_ipv6
Enable/disable getting a public IPv6 on this digitalocean-droplet.
 - Default: false

### digitalocean_private_networking
Enable/disable private-networking functionality on this digitalocean-droplet.
 - Default: false

### digitalocean_volume0
Volume0 to attach to this digitalocean-droplet in the format `<mount-point>:<mount-device>:<volume-id>:<mount-fstype>`
 - Default: ""


## Outputs

### hostname
The hostname applied to this digitalocean-droplet.

### region
The digitalocean region-slug this digitalocean-droplet is running in.

### ipv4_address
The public IPv4 address of this digitalocean-droplet.

### volume0
The volume attach to this digitalocean-droplet in the format `<mount-point>:<mount-device>:<volume-id>:<mount-fstype>`

### terraform_bootstrap_sshkey
The terraform-bootstrap-sshkey that was used to bootstrap this droplet.

### salt_local_minion_config_file

### salt_local_state_tree

### salt_local_pillar_roots

### salt_remote_state_tree

### salt_remote_pillar_roots


## Authors
Module managed by [Nicholas de Jong](https://github.com/ndejong).

## License
Apache 2 Licensed. See LICENSE for full details.
