provider "aws" {
  region = var.region
}

provider "helm" {
  alias = "helm-support-services"
  kubernetes {
    config_path = "${var.project_root_path}/admin-support-services.conf"
  }
}
provider "kubernetes" {
  alias       = "k8s-support-services"
  config_path = "${var.project_root_path}/admin-support-services.conf"
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    region = var.region
    bucket = "##tenant##-mojaloop-state"
    key    = "##environment##/terraform.tfstate"
  }
}
