# terraform-digitalocean-salt-masterless
# ============================================================================

# Copyright (c) 2018 Verb Networks Pty Ltd <contact [at] verbnetworks.com>
#  - All rights reserved.
#
# Apache License v2.0
#  - http://www.apache.org/licenses/LICENSE-2.0

# create a unique build-id value for this startup process
# ===
resource "random_string" "random-chars" {
  length = 6
  lower = false
  upper = true
  number = true
  special = false
}

# Generate a temporary ssh keypair to bootstrap this instance
# ===
resource "tls_private_key" "terraform-bootstrap-sshkey" {
  algorithm = "RSA"
  rsa_bits = "4096"
}

# attach the temporary sshkey to the provider account for this image build
# ===
# !!!  NB: this ssh key remains in CLEAR TEXT in the terraform.tfstate file and can be extracted using:-
# !!!  $ cat terraform.tfstate | jq --raw-output '.modules[1].resources["tls_private_key.terraform-bootstrap-sshkey"].primary.attributes.private_key_pem'
# ===
resource "digitalocean_ssh_key" "terraform-bootstrap-sshkey" {
  name = "terraform-bootstrap-sshkey-${random_string.random-chars.result}"
  public_key = "${tls_private_key.terraform-bootstrap-sshkey.public_key_openssh}"
  depends_on = [ "random_string.random-chars", "tls_private_key.terraform-bootstrap-sshkey" ]
}

# Render the required userdata
# ===
data "template_file" "cloudinit-bootstrap-sh" {
  template = "${file("${path.module}/data/cloudinit-bootstrap.sh")}"
  vars {
    volume0_dev = "${element(split(":", var.digitalocean_volume0),1)}"
    volume0_mount = "${element(split(":", var.digitalocean_volume0),0)}"
    volume0_fstype = "${element(split(":", var.digitalocean_volume0),3)}"
  }
}

# create the cloudinit user-data string to apply to this droplet
# ===
data "template_cloudinit_config" "droplet-userdata" {

  # NB: some kind of cloud-init issue prevents gzip+base64 from working with digitalocean, we (mostly) work around this
  # using a " echo | base64 -d | gunzip | /bin/bash" style pipe chain as per below
  #
  gzip = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename = "cloudinit-bootstrap.sh"
    content = "#!/bin/sh\necho -n '${base64gzip(data.template_file.cloudinit-bootstrap-sh.rendered)}' | base64 -d | gunzip | /bin/sh"
  }
}

# Establish the digitalocean_droplet with a salt-masterless provisioner
# ===
resource "digitalocean_droplet" "droplet" {
  image = "${var.digitalocean_image}"
  name = "${var.hostname}"
  region = "${var.digitalocean_region}"
  size = "${var.digitalocean_size}"
  backups = "${var.digitalocean_backups}"
  monitoring = "${var.digitalocean_monitoring}"
  ipv6 = "${var.digitalocean_ipv6}"
  private_networking = "${var.digitalocean_private_networking}"
  ssh_keys = [ "${digitalocean_ssh_key.terraform-bootstrap-sshkey.id}" ]
  depends_on = [ "digitalocean_ssh_key.terraform-bootstrap-sshkey" ]

  volume_ids = [ "${element(split(":", var.digitalocean_volume0),2)}" ]
  user_data = "${data.template_cloudinit_config.droplet-userdata.rendered}"

  connection {
    type = "ssh"
    user = "root"
    timeout = "300"
    agent = false
    private_key = "${tls_private_key.terraform-bootstrap-sshkey.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -e '/var/lib/cloud/instance/boot-finished' ]; do sleep 1; done",
      "mkdir -p `dirname \"${var.salt_remote_state_tree}\"`",
      "mkdir -p `dirname \"${var.salt_remote_pillar_roots}\"`",
    ]
  }

  provisioner "remote-exec" {

    #
    # this is a workaround for salt-masterless:minion_config_file issue described in provisioner:salt-masterless below
    #

    inline = [
      "if [ '${var.salt_local_minion_config_file}' != '/dev/null' ]; then mkdir -p /etc/salt; echo '${base64gzip(file("${var.salt_local_minion_config_file}"))}' | base64 -d | gunzip > /etc/salt/minion; fi",
    ]
  }

  provisioner "salt-masterless" {

    #
    # as at commit:e9e4ee4 there seems to be a bug in https://github.com/hashicorp/terraform/blob/master/builtin/provisioners/salt-masterless/resource_provisioner.go
    # that is preventing p.RemoteStateTree and p.RemotePillarRoots being set when p.MinionConfig == "" which in turn
    # means it is not currently possible to use the "minion_config_file" option in this module until resolved
    #
    # minion_config_file = "${var.salt_local_minion_config_file}"
    #

    local_state_tree = "${var.salt_local_state_tree}"
    local_pillar_roots = "${var.salt_local_pillar_roots}"

    remote_state_tree = "${var.salt_remote_state_tree}"
    remote_pillar_roots = "${var.salt_remote_pillar_roots}"

    custom_state = "${var.salt_custom_state}"
    log_level = "${var.salt_log_level}"
  }
}

# by default we disable the salt-minion service because this is a "headless" arrangement where changes are manually
# driven by invoking `salt-call`
# ===
resource "null_resource" "disable-saltminion-service" {
  count = "${var.disable_saltminion_service}"

  connection {
    host = "${digitalocean_droplet.droplet.ipv4_address}"
    type = "ssh"
    user = "root"
    timeout = "300"
    agent = false
    private_key = "${tls_private_key.terraform-bootstrap-sshkey.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "export LANGUAGE='en_US.UTF-8'; export LANG='en_US.UTF-8'; export LC_ALL='en_US.UTF-8'",  # for this remote-exec session only
      "systemctl stop salt-minion",
      "systemctl disable salt-minion",
    ]
  }

  depends_on = [ "digitalocean_droplet.droplet" ]
}

# cleanup and remove the root account if configured to do so
# ===
resource "null_resource" "disable-root-login" {
  count = "${var.disable_root_login}"

  connection {
    host = "${digitalocean_droplet.droplet.ipv4_address}"
    type = "ssh"
    user = "root"
    timeout = "300"
    agent = false
    private_key = "${tls_private_key.terraform-bootstrap-sshkey.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",  # ugly hack to handle the race condition between "droplet-permitrootlogin" and "disable-saltminion-service" combined with the imposibility of var.disable_saltminion_service = 0
      "sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config",
      "rm -f /root/.ssh/authorized_keys",
      "rm -f /root/.ssh/*.pub",
    ]
  }

  depends_on = [ "digitalocean_droplet.droplet" ]
}
