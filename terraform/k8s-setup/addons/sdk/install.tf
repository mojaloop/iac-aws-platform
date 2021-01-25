locals {
  sdk_details = {
    (var.name) = {
      sim_name              = var.name
      sim_password          = "${var.name}123"
      sim_callback_url      = "https://${var.haproxy_callback_private_ip}/mockfsp/${var.name}/inbound"
      subscribe_to_api_list = "FSPIOP"
    }
  }
  wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
}

data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}


module "provision_sdks_to_wso2" {
  source            = "git::git@github.com:mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v0.0.2"
  extgw_fqdn        = var.extgw_fqdn
  test_user_details = local.sdk_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

module "provision_sdk_callbacks_to_wso2" {
  source            = "git::git@github.com:mojaloop/iac-shared-modules.git//wso2/callbacks-post-config?ref=v0.0.2"
  intgw_fqdn        = var.intgw_fqdn
  test_user_details = local.sdk_details
  fspiop_version    = split(".", var.helm_mojaloop_version)[0] == "11" ? "1.1" : "1.0"
  user              = "admin"
  password          = local.wso2_admin_pw
}
