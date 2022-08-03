terraform {
  required_version = ">= 1.1"
  backend "s3" {
    key = "##environment##/terraform-k8s-postinstall.tfstate"
  }
  required_providers {
    helm = "~> 2.3"
    vault = "~> 3.0"
    kubernetes = "~> 2.6"
    external = "~> 1.2.0"
    restapi = {
      source = "Mastercard/restapi"
      version = "~> 1.16.2"
    }
  }
}

locals {
  vault_addr = "https://vault.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
  switch_pem = tomap({
                  "switch.pem" = data.terraform_remote_state.support-svcs.outputs.switch_jws_key
                })

  jws_pub    = local.switch_pem
}

provider "external" {
  alias   = "v1_2_0"
}

provider "aws" {
  region = var.region
}

provider "vault" {
  address = local.vault_addr
  token   = jsondecode(file("${var.project_root_path}/vault_seal_key"))["root_token"]
}

data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}

data "terraform_remote_state" "support-svcs" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.bucket
    key    = "${var.environment}/terraform-suppsvcs.tfstate"
  }
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.bucket
    key    = "${var.environment}/terraform.tfstate"
  }
}

data "terraform_remote_state" "k8s-base" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.bucket
    key    = "${var.environment}/terraform-k8s.tfstate"
  }
}

data "terraform_remote_state" "tenant" {
  backend = "s3"
  config = {
    region = var.region
    bucket = var.bucket
    key    = "bootstrap/terraform.tfstate"
  }
}