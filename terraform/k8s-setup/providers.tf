terraform {
  required_version = ">= 0.13.5"
  backend "s3" {
    key     = "##environment##/terraform-k8s.tfstate"
    encrypt = true
  }
  required_providers {
    helm  = "1.2.4"
    vault = "2.10.0"
    kubernetes = "~> 1.13.3"
    tls = "~> 2.0"
    external = "~> 1.2.0"
  }
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

##########################
#       ADD-ONS
#########################
provider "helm" {
  alias = "helm-add-ons"
  kubernetes {
    config_path = "${var.project_root_path}/admin-add-ons.conf"
  }
}
provider "kubernetes" {
  alias       = "k8s-add-ons"
  config_path = "${var.project_root_path}/admin-add-ons.conf"
}

###########################
#        MOJALOOP
###########################
/* provider "helm" {
  alias = "helm-mojaloop"
  kubernetes {
    config_path = "${var.project_root_path}/admin-mojaloop.conf"
  }
}
provider "kubernetes" {
  alias       = "k8s-mojaloop"
  config_path = "${var.project_root_path}/admin-mojaloop.conf"
} */

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

############################
#          SUPPORT-SERVICES
############################
/* provider "helm" {
  alias = "helm-support-services"
  kubernetes {
    config_path = "${var.project_root_path}/admin-support-services.conf"
  }
}
provider "kubernetes" {
  alias       = "k8s-support-services"
  config_path = "${var.project_root_path}/admin-support-services.conf"
} */

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
