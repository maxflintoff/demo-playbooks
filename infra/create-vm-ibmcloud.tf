variable "ibmcloud_api_key" {}
variable "iaas_classic_username" {}
variable "iaas_classic_api_key" {}
variable "region" {}
variable "name_prefix" {}
variable "ssh_key" {}
variable "flavor" {}
variable "os" {}
variable "datacenter" {}
variable "domain" {}
variable "tags" {
    type = list(string)
}

provider "ibm" {
ibmcloud_api_key = var.ibmcloud_api_key
generation = 1
region = var.region
iaas_classic_username = var.iaas_classic_username
iaas_classic_api_key  = var.iaas_classic_api_key
}

data "ibm_compute_ssh_key" "public_key" {
    label = "${var.name_prefix}-ssh"
}

locals {
    existing_key = var.ssh_key != data.ibm_compute_ssh_key.public_key.public_key
}

resource "ibm_compute_ssh_key" "ssh_key" {
    count = local.existing_key ? 1 : 0
    label = "${var.name_prefix}-ssh"
    notes = "created automatically"
    public_key = var.ssh_key
}

locals {
    ssh_key_id = local.existing_key ? ibm_compute_ssh_key.ssh_key[0].id : data.ibm_compute_ssh_key.public_key.id
}

resource "ibm_compute_vm_instance" "vm" {
  hostname                   = "${var.name_prefix}-vm"
  domain = var.domain
  flavor_key_name            = var.flavor
  os_reference_code          = var.os
  datacenter                 = var.datacenter
  network_speed              = 1000
  ssh_key_ids                = [local.ssh_key_id]
  local_disk                 = false
  tags                       = var.tags
}

output "vm_details" {
    value = ibm_compute_vm_instance.vm
}