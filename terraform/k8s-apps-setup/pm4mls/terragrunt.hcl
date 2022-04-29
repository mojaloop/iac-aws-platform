generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = < < EOF
terraform { 
  required_version = get_env("tf_version")
 
  required_providers {
    local = {
      source = "hashicorp/local"
      version = get_env("local_provider_version")
    }
    external = get_env("external_provider_version")
  }

  backend "s3" {}
}

EOF
}

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "baseinfra" {
  config_path = "../../base-infra-aws"
}

inputs = merge(yamldecode(file(${find_in_parent_folders("provider_versions.yaml"}))), yamldecode(file(${find_in_parent_folders("common_vars.yaml"}))))