generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
terraform { 
  required_version = "${local.common_vars.tf_version}"
 
  required_providers {
    vault = "${local.common_vars.vault_provider_version}"
    local = {
      source = "hashicorp/local"
      version = "${local.common_vars.local_provider_version}"
    }
    external = "${local.common_vars.external_provider_version}"
  }
}
EOF
}

generate "vault_provider" {
  path = "vault_provider.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
provider "vault" {
  address = "https://vault.${dependency.baseinfra.outputs.public_subdomain}"
  token   = jsondecode(file("${local.common_vars.vault_token_location}"))["root_token"]
}
 
EOF
}

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "baseinfra" {
  config_path = "../../base-infra-aws"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
  public_subdomain = dependency.baseinfra.outputs.public_subdomain
}