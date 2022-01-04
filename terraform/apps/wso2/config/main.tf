terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key     = "##environment##/wso2/extgw/terraform.tfstate"
    encrypt = true
  }
  required_providers {
    ansible = {
      source  = "nbering/ansible"
      version = "~> 1.0"
    }
    vault = "~> 3.0"
  }
}

locals {
  vault_addr = "https://vault.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
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

data "terraform_remote_state" "mojaloop" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "${var.environment}/terraform-k8s.tfstate"
  }
}

resource "ansible_host" "api_publisher" {
  inventory_hostname = "localhost"
  vars = {
    external_domain = data.terraform_remote_state.infrastructure.outputs.public_subdomain
    internal_domain = data.terraform_remote_state.infrastructure.outputs.private_subdomain
    ml_version = "v${data.terraform_remote_state.mojaloop.outputs.helm_mojaloop_version}"
    wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
  }
}
