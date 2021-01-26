provider "kubernetes" {
  version     = "~> 1.13"
  config_path = var.kubeconfig
}

provider "tls" {
  version = "~> 2.0"
}

provider "helm" {
  # force Helm v2 usage
  version = "~> 0.10.6"
  kubernetes {
    config_path = var.kubeconfig
  }
}
