terraform {
  required_version = ">= 1.0"
  required_providers {
    helm = "~> 2.3"
    kubernetes = "~> 2.6"
    tls = "~> 2.0"
    aws = "~> 3.74"
  }
}
