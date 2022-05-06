generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
terraform { 
  required_version = "${local.common_vars.tf_version}"
 
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "${local.common_vars.local_provider_version}"
    }
    external = "${local.common_vars.external_provider_version}"
    vault = "${local.common_vars.vault_provider_version}"    
    restapi = {
      source = "Mastercard/restapi"
      version = "${local.common_vars.restapi_provider_version}"
    }
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

generate "data_tenancy" {
  path = "data_tenancy.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
data "terraform_remote_state" "tenant" {
  backend = "s3"
  config = {
    region = "${get_env("region")}"
    bucket = "${get_env("client")}-mojaloop-state"
    key    = "bootstrap/terraform.tfstate"
  }
}
EOF
}

generate "restapi_provider" {
  path = "restapi_provider.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
provider "restapi" {
  alias                = "restapi_mcm"
  uri                  = "https://${dependency.supportsvcs.outputs.mcm_fqdn}"
  debug                = true
  write_returns_object = false
  create_returns_object = true

  oauth_client_credentials {
    oauth_client_id = "${dependency.supportsvcs.outputs.mcm_portal_client_id}"
    oauth_client_secret = "${dependency.supportsvcs.outputs.mcm_portal_client_secret}"
    oauth_token_endpoint = "https://${dependency.supportsvcs.outputs.iskm_fqdn}:443/oauth2/token"
    oauth_scopes = ["openid"]
  }
}
 
EOF
}

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "baseinfra" {
  config_path = "../../base-infra-aws"
}
dependency "supportsvcs" {
  config_path = "../support-svcs"
}
dependency "mojaloopcore" {
  config_path = "../mojaloop-core"
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}
inputs = {
  public_subdomain = dependency.baseinfra.outputs.public_subdomain
  private_subdomain = dependency.baseinfra.outputs.private_subdomain
  switch_jws_key = dependency.supportsvcs.outputs.switch_jws_key
  mfi-p2p-oracle-fqdn = dependency.mojaloopcore.outputs.mfi-p2p-oracle-fqdn
  mfi-account-oracle-fqdn = dependency.mojaloopcore.outputs.mfi-account-oracle-fqdn
  alias-oracle-fqdn = dependency.mojaloopcore.outputs.alias-oracle-fqdn
  sim_whitelist_secret_name = dependency.supportsvcs.outputs.sim_whitelist_secret_name
  mcm_fqdn = dependency.supportsvcs.outputs.mcm_fqdn
}