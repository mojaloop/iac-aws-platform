generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
terraform { 
  required_version = ${get_env("tf_version")}
 
  required_providers {
    aws = ${get_env("aws_provider_version")}
    local = {
      source = "hashicorp/local"
      version = ${get_env("local_provider_version")}
    }
  }

  backend "s3" {}
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
    region = ${get_env("region")}
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

inputs = yamldecode(file(find_in_parent_folders("provider_versions.yaml")))