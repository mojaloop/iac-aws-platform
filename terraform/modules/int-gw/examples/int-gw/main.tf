module "int_gw" {
  source = "../.."

  kubeconfig    = "kube.conf"
  contact_email = "example@example.com"
  hostname      = "intgw"
  bucket        = "example-state"
  environment   = "dev"
}

terraform {
  backend "s3" {
    key = "dev/modules/int-gw/terraform.tfstate"
  }
}
