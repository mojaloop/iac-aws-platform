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
}

EOF
}

generate "k8s_provider" {
  path = "k8s_providers.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
provider "helm" {
  alias = "helm-main"
  kubernetes {
    config_path = "${local.common_vars.kubeconfig_location}"
  }
}
provider "kubernetes" {
  alias       = "k8s-main"
  config_path = "${local.common_vars.kubeconfig_location}"
}

provider "kubectl" {
  alias       = "k8s-main"
  config_path = "${local.common_vars.kubeconfig_location}"
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
dependency "supportsvcs" {
  config_path = "../support-svcs"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
  public_subdomain = dependency.baseinfra.outputs.public_subdomain
  private_subdomain = dependency.baseinfra.outputs.private_subdomain
  interop_switch_private_fqdn = dependency.baseinfra.outputs.interop_switch_private_fqdn
  switch_jws_private_key = dependency.supportsvcs.outputs.switch_jws_private_key
  bof_custom_resources_dir = local.common_vars.bof_custom_resources_dir
}