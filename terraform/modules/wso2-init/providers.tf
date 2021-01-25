provider "aws" {
  version = "~> 2.54"
  region  = var.region
}

provider "tls" {
  version = "~> 2.0"
}


provider "kubernetes" {
  version     = "~> 1.11"
  config_path = var.kubeconfig
}

provider "helm" {
  # force Helm v2 usage
  version = "~> 0.10.6"
  kubernetes {
    config_path = var.kubeconfig
  }
}
