terraform {
  required_version = ">= 1.0"
  required_providers {
    helm = "1.2.4"
    kubernetes = "~> 1.13.3"
    tls = "~> 2.0"
  }
}