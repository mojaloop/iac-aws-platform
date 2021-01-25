terraform {
  required_version = ">= 0.13"
  backend "s3" {
    key     = "##environment##/sdk_vms.tfstate"
    encrypt = true
  }
}

variable "tenant" {}
variable "environment" {}
variable "region" {}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.tenant}-mojaloop-state"
    key    = "${var.environment}/terraform.tfstate"
  }
}

data "terraform_remote_state" "tenant" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.tenant}-mojaloop-state"
    key    = "bootstrap/terraform.tfstate"
  }
}

module "sdk_vms" {
  source            = "git::git@github.com:mojaloop/iac-shared-modules.git//aws/sdks?ref=v0.0.2"
  region            = var.region
  domain            = data.terraform_remote_state.infrastructure.outputs.public_subdomain
  client_node_count = 0
  client            = var.tenant
  environment       = var.environment
  allow_cbs_access = [
    "${data.terraform_remote_state.tenant.outputs.wireguard_public_ip}/32",
    "${data.terraform_remote_state.tenant.outputs.gitlab_ci_public_ip}/32"
    # callback/nat gateway
    # hotel isp range
  ]
  allow_sdk_access = [
    "${data.terraform_remote_state.tenant.outputs.wireguard_public_ip}/32",
    "${data.terraform_remote_state.tenant.outputs.gitlab_ci_public_ip}/32"
    # callback/nat gateway
    # hotel isp range
  ]
  allow_ssh_access = [
    "${data.terraform_remote_state.tenant.outputs.wireguard_public_ip}/32"
  ]
  sdks = [
    # {
    #   name               = "emoments",
    #   port               = "4000",
    #   sim_port           = "3003",
    #   account_id         = "ACC011111",
    #   instance           = "0",
    #   currency           = "UGX",
    #   msisdn             = "256111111111",
    #   business_id        = "emomentsMerchant",
    #   notification_email = "test@emomentsMerchant.com"
    # }
  ]
}

output "publicIPs" {
  description = "List of nodes public IPs, json encoded"
  value       = module.sdk_vms.publicIPs
}

output "hosts" {
  description = "List of nodes hostnames, json encoded"
  value       = module.sdk_vms.hosts
}

output "dfsp_data" {
  description = "JSON object describing the dfsps and their endpoints"
  value       = module.sdk_vms.dfsp_data
}

output "domain" {
  description = "Base domain into which the VMs and dfsps are created"
  value       = module.sdk_vms.domain
}
