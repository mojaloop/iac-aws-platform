locals {
  account_details = {
    "hub_operator" = {
      sim_name              = "hub_operator"
      sim_password          = vault_generic_secret.hub_operator_password.data.value
      subscribe_to_api_list = "CentralLedgerAdminAPI,CentralSettlementsAPI,ALSAdminAPI,FSPIOP"
    }
  }
}

module "provision_accounts_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v2.0.0"
  extgw_fqdn        = "extgw-mgmt-int.${dependency.baseinfra.outputs.public_subdomain}"
  token_extgw_fqdn  = "extgw-data-int.${dependency.baseinfra.outputs.public_subdomain}"
  extgw_token_service_port = 443
  extgw_admin_port = 443
  test_user_details = local.account_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

resource "random_password" "hub_operator_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "hub_operator_password" {
  path = "secret/mojaloop/huboperatorpw"

  data_json = jsonencode({
    "value" = random_password.hub_operator_password.result
  })
}
