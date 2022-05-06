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
    tls = "${local.common_vars.tls_provider_version}"
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

dependency "baseinfra" {
  config_path = "../../base-infra-aws"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

inputs = {
  kubeconfig_location = local.common_vars.kubeconfig_location
  gitlab_hostname = dependency.baseinfra.outputs.gitlab_hostname
  public_subdomain = dependency.baseinfra.outputs.public_subdomain
  private_subdomain = dependency.baseinfra.outputs.private_subdomain
  internal_load_balancer_dns = dependency.baseinfra.outputs.internal_load_balancer_dns
  k8s_worker_nodes_private_ip = dependency.baseinfra.outputs.k8s_worker_nodes_private_ip
  vault_addr = "https://vault.${dependency.baseinfra.outputs.public_subdomain}"
}