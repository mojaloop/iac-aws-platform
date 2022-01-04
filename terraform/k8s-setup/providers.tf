terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key     = "##environment##/terraform-k8s.tfstate"
    encrypt = true
  }
  required_providers {
    helm = "~> 2.3"
    vault = "~> 3.0"
    kubernetes = "~> 2.6"
    tls = "~> 2.0"
    external = "~> 1.2.0"
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

locals {
  vault_addr = "https://vault.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

provider "external" {
  alias = "wso2-automation-iskm-mcm"
}

provider "aws" {
  region = var.region
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


data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform.tfstate"
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

data "terraform_remote_state" "support-svcs" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform-suppsvcs.tfstate"
  }
}

data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}