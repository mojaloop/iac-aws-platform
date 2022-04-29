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