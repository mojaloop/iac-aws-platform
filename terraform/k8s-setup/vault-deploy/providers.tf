
terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key     = "##environment##/terraform-vault.tfstate"
    encrypt = true
  }
  required_providers {
    helm = "~> 2.3"
    kubernetes = "~> 2.6"
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13"
    }
    aws = "~> 3.74"
  }
}

provider "aws" {
  region = var.region
}

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
