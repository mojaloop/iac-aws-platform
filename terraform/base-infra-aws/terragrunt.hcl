generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
terraform { 
  required_version = "${local.common_vars.tf_version}"
 
  required_providers {
    aws = "${local.common_vars.aws_provider_version}"
    local = {
      source = "hashicorp/local"
      version = "${local.common_vars.local_provider_version}"
    }
  }
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
locals {
  public_zone_id = data.terraform_remote_state.tenant.outputs.public_zone_id
  private_zone_id = data.terraform_remote_state.tenant.outputs.private_zone_id
  public_subdomain = data.terraform_remote_state.tenant.outputs.public_zone_name
  private_subdomain = data.terraform_remote_state.tenant.outputs.private_zone_name
  gitlab_hostname = data.terraform_remote_state.tenant.outputs.gitlab_hostname
  gitlab_root_token = data.terraform_remote_state.tenant.outputs.gitlab_root_token
  nexus_fqdn = data.terraform_remote_state.tenant.outputs.nexus_fqdn
  nexus_docker_repo_listening_port = data.terraform_remote_state.tenant.outputs.nexus_docker_repo_listening_port
  vpc_id = data.terraform_remote_state.tenant.outputs.vpc_id
  availability_zones = data.terraform_remote_state.tenant.outputs.availability_zones
  private_subnet_ids = data.terraform_remote_state.tenant.outputs.private_subnet_ids
  public_subnet_ids = data.terraform_remote_state.tenant.outputs.public_subnet_ids
}

EOF
}

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}
include "aws_provider" {
  path = find_in_parent_folders("aws_provider.hcl")
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}