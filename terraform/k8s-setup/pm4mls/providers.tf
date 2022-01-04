terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key = "##environment##/terraform-k8s-pm4mls.tfstate"
  }

  required_providers {
    helm = "~> 2.3"
    vault = "~> 3.0"
    kubernetes = "~> 2.6"
    external = "~> 1.2.0"
  }
}

provider "aws" {
  region = var.region
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

provider "external" {
  alias   = "v1_2_0"
}

locals {
  vault_addr = "https://vault.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
}

data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform.tfstate"
  }
}

data "terraform_remote_state" "k8s-base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform-k8s.tfstate"
  }
}

data "terraform_remote_state" "suppsvcs" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform-suppsvcs.tfstate"
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