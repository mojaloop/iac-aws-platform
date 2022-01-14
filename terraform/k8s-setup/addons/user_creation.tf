locals {
  account_details = {
    "hub_operator" = {
      sim_name              = "hub_operator"
      sim_password          = "hub_operator123"
      subscribe_to_api_list = "CentralLedgerAdminAPI,CentralSettlementsAPI,ALSAdminAPI,FSPIOP"
    }
    "noresponsepayeefsp" = {
      sim_name              = "noresponsepayeefsp"
      sim_password          = "noresponsepayeefsp123"
      subscribe_to_api_list = "FSPIOP"
    }
  }
}

module "provision_accounts_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v2.0.0"
  extgw_fqdn        = "extgw-mgmt-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  token_extgw_fqdn  = "extgw-data-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  extgw_token_service_port = 443
  extgw_admin_port = 443
  test_user_details = local.account_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}
