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

dependency "baseinfra" {
  config_path = "../base-infra-aws"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
  kubeconfig_location = local.common_vars.kubeconfig_location
  static_files_path_location = local.common_vars.static_files_path_location
  private_subdomain_zone_id = dependency.baseinfra.outputs.private_zone_id
  public_subdomain_zone_id = dependency.baseinfra.outputs.public_subdomain_zone_id
  private_subdomain = dependency.baseinfra.outputs.private_subdomain
  public_subdomain = dependency.baseinfra.outputs.public_subdomain
  external_load_balancer_dns = dependency.baseinfra.outputs.external_load_balancer_dns
  internal_load_balancer_dns = dependency.baseinfra.outputs.internal_load_balancer_dns
  available_zones = dependency.baseinfra.outputs.available_zones
}