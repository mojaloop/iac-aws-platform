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
    helm = "${local.common_vars.helm_provider_version}"
    kubernetes = "${local.common_vars.kubernetes_provider_version}"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "${local.common_vars.kubectl_provider_version}"
    }
    vault = "${local.common_vars.vault_provider_version}"
    external = "${local.common_vars.external_provider_version}"
  }

  backend "s3" {}
}
EOF
}

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}
include "k8s_providers" {
  path = find_in_parent_folders("k8s_providers.hcl")
}
include "vault_provider" {
  path = find_in_parent_folders("vault_provider.hcl")
}
dependency "baseinfra" {
  config_path = "../../base-infra-aws"
}
dependency "basek8s" {
  config_path = "../../base-k8s-aws"
}
dependency "supportsvcs" {
  config_path = "../support-svcs"
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}
inputs = {
  kubeconfig_location = ${local.common_vars.kubeconfig_location}
  vault_token_location = ${local.common_vars.vault_token_location}
}