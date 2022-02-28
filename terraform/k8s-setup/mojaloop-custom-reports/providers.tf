terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key = "##environment##/terraform-k8s-mojaloop-custom-reports.tfstate"
  }
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.3"
    }
    kubernetes = {
      version = "~> 2.6"
    }
    vault = "~> 2.24"
  }
}

##########################
#       ADD-ONS
#########################
provider "helm" {
  alias = "helm-gateway"
  kubernetes {
    config_path = "${var.project_root_path}/admin-gateway.conf"
  }
}

provider "kubernetes" {
  config_path = "${var.project_root_path}/admin-gateway.conf"
}
