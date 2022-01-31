terraform {
  required_version = ">= 1.0"
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
    keycloak = {
      source = "mrparkers/keycloak"
      version = ">= 2.0.0"
    }
  }
}
provider "external" {
  alias = "wso2-automation-iskm-mcm"
}
locals {
  #kube_master_url = yamldecode(file("${var.project_root_path}/admin-gateway.conf"))["clusters"].cluster[0].server
  vault_addr = "https://vault.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  kube_master_url = "https://${data.terraform_remote_state.infrastructure.outputs.gateway_k8s_master_nodes_private_ip[0]}:6443"
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

provider "tls" {
  alias = "wso2"
}

provider "keycloak" {
  client_id     = "admin-cli"
  username      = "user"
  password      = vault_generic_secret.keycloak_pw.data.value
  initial_login = false
  url           = "https://keycloak.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
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
