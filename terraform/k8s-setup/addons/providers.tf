terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key = "##environment##/terraform-k8s-postinstall.tfstate"
  }
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 1.2.4"
    }
    kubernetes = {
      version = "~> 1.13.3"
    }
  }
}

provider "aws" {
  region = var.region
}

##########################
#       ADD-ONS
#########################
provider "helm" {
  kubernetes {
    config_path = "${var.project_root_path}/admin-add-ons.conf"
  }
}

provider "kubernetes" {
  config_path = "${var.project_root_path}/admin-add-ons.conf"
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

data "terraform_remote_state" "tenant" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "${var.client}-mojaloop-state"
    key    = "bootstrap/terraform.tfstate"
  }
}

provider "external" {
  alias   = "v1_2_0"
  version = "~> 1.2.0"
}
