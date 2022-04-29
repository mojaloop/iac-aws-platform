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
    helm = "${local.common_vars.helm_provider_version}"
    kubernetes = "${local.common_vars.kubernetes_provider_version}"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "${local.common_vars.kubectl_provider_version}"
    }
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
include "k8s_providers" {
  path = find_in_parent_folders("k8s_providers.hcl")
}

dependency "baseinfra" {
  config_path = "../base-infra-aws"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}
inputs = {
  kubeconfig_location = ${local.common_vars.kubeconfig_location}
}