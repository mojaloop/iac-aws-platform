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
  source            = "git::git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v1.0.17"
  extgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  test_user_details = local.account_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}
