terraform {
  required_version = ">= 1.1"
  backend "s3" {
    key     = "##environment##/terraform-suppsvcs.tfstate"
    encrypt = true
  }
  required_providers {
    helm = "~> 2.3"
    vault = "~> 3.0"
    kubernetes = "~> 2.6"
    tls = "~> 2.0"
    external = "~> 1.2.0"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13"
    }
  }
}

provider "external" {
  alias = "wso2-automation-iskm-mcm"
}

locals {
  vault_addr = "https://vault.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  kube_master_url = "https://${data.terraform_remote_state.infrastructure.outputs.internal_load_balancer_dns}:6443"
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

provider "tls" {
  alias = "wso2"
}
############################
#          GATEWAY
############################
provider "helm" {
  alias = "helm-gateway"
  kubernetes {
    config_path = "${var.project_root_path}/admin-gateway.conf"
  }
}

provider "kubernetes" {
  alias       = "k8s-gateway"
  config_path = "${var.project_root_path}/admin-gateway.conf"
}

provider "kubectl" {
  alias       = "k8s-gateway"
  config_path = "${var.project_root_path}/admin-gateway.conf"
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform.tfstate"
  }
}

data "terraform_remote_state" "vault" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform-vault.tfstate"
  }
}

data "terraform_remote_state" "tenant" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "bootstrap/terraform.tfstate"
  }
}
