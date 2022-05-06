generate "versions" {
  path = "versions.tf"
 
  if_exists = "overwrite_terragrunt"
 
  contents = <<EOF
terraform { 
  required_version = "${local.common_vars.tf_version}"
 
  required_providers {
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

include "state" {
  path = find_in_parent_folders("remote_state.hcl")
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
  bof_custom_resources_dir = local.common_vars.bof_custom_resources_dir
}