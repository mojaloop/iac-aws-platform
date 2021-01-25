module "wso2_init" {
  source = "../.."

  kubeconfig = "kube.conf"
  environment = "dev"
  bucket = "mojaloop-wkbench-mbox-dev-state"
  mysql_version = "1.6.1"
  db_root_password = "123soleil"
  db_password = "123soleil"
#   env_sg_id = 
}

terraform {
  backend "s3" {
    key = "dev/modules/wso2-init/terraform.tfstate"
  }
}

output "root_private_key" {
  description = "Private key for root CA"
  value = module.wso2_init.root_private_key
}

output "root_certificate" {
  description = "Self signed root CA"
  value = module.wso2_init.root_certificate
}
