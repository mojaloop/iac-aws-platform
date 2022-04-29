generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
terraform { 
  required_version = "${local.common_vars.tf_version}"
 
  required_providers {
    vault = "${local.common_vars.vault_provider_version}"
    ansible = {
      source  = "nbering/ansible"
      version = "${local.common_vars.ansible_provider_version}"
    }
  }
}
EOF
}

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}
include "ansible_provider" {
  path = find_in_parent_folders("ansible_provider.hcl")
}
include "vault_provider" {
  path = find_in_parent_folders("vault_provider.hcl")
}
dependency "baseinfra" {
  config_path = "../../base-infra-aws"
}
dependency "mojaloopcore" {
  config_path = "../mojaloop-core"
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}
inputs = {
  vault_token_location = ${local.common_vars.vault_token_location}
}