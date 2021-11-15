terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key     = "##environment##/terraform-k8s-mojaloop-roles.tfstate"
    encrypt = true
  }
  required_providers {    
    kubernetes = "~> 2.6"  
  }
}

provider "kubernetes" {
  alias       = "k8s-gateway"
  config_path = "${var.project_root_path}/admin-gateway.conf"
}