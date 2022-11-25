
resource "local_file" "gen_ansible_output" {
  content         = yamlencode(local.internal_pm4ml_output)
  filename        = "${path.root}/ansible_internal_pm4ml_output.yaml"
  file_permission = "0644"
}

resource "local_file" "gen_postman_output" {
  content         = jsonencode(local.internal_postman_pm4ml_output)
  filename        = "${path.root}/onboarding_internal_pm4ml_output.json"
  file_permission = "0644"
}

locals {
  internal_pm4ml_details = {
    for pm4ml_config in var.internal_pm4ml_configs :
    pm4ml_config.DFSP_NAME => {
      sim_name              = pm4ml_config.DFSP_NAME
      sim_password          = "${pm4ml_config.DFSP_NAME}123"
      sim_callback_url      = "https://haproxy-callback.wso2.svc.cluster.local/fsp/${pm4ml_config.DFSP_NAME}/inbound"
      subscribe_to_api_list = "FSPIOP"
    }
  }
  internal_pm4ml_output = {
    for pm4ml_config in var.internal_pm4ml_configs :
    pm4ml_config.DFSP_NAME => {      
      "pm4ml_instance_name"  = pm4ml_config.DFSP_NAME
      "pm4ml_subdomain"      = "${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      "mcm_auth_enabled"     = true
      "mcm_auth_user"        = pm4ml_config.DFSP_NAME
      "mcm_auth_pass"        = "${pm4ml_config.DFSP_NAME}123"
      "dfsp_id"              = pm4ml_config.DFSP_NAME
      "extgw_fqdn"           = "extgw-data.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      "mcm_host_url"         = "mcm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      "helm_release_name"    = pm4ml_config.DFSP_NAME
      "ttk_enabled"          = false
      "extgw_client_key"     = module.internal_provision_pm4ml_to_wso2.client-ids[pm4ml_config.DFSP_NAME]
      "extgw_client_secret"  = module.internal_provision_pm4ml_to_wso2.client-secrets[pm4ml_config.DFSP_NAME]
      "OAUTH_TOKEN_ENDPOINT" = "https://extgw-data.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}:443/oauth2/token"
    }
  }
  internal_postman_pm4ml_output = [
    for pm4ml_config in var.internal_pm4ml_configs :
    {
      "DFSP_NAME" = pm4ml_config.DFSP_NAME
      "DFSP_CURRENCY" = pm4ml_config.DFSP_CURRENCY
      "DFSP_MSISDN" = pm4ml_config.DFSP_MSISDN
      "GENERIC_DFSP_CALLBACK_URL" = "https://intgw-data-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}:443/${pm4ml_config.DFSP_NAME}/1.0"
      "GENERIC_DFSP_BACKEND_TESTAPI_URL" = "http://test.${pm4ml_config.DFSP_NAME}.${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}/sim-backend-test"
      "DFSP_ACCOUNT_ID" = pm4ml_config.DFSP_ACCOUNT_ID
      "DFSP_ALIAS_ID" = pm4ml_config.DFSP_ALIAS_ID
      "DFSP_NOTIFICATION_EMAIL" = pm4ml_config.DFSP_NOTIFICATION_EMAIL
      "PARTY_FULL_NAME" = "${pm4ml_config.PARTY_FIRST_NAME} ${pm4ml_config.PARTY_LAST_NAME}"
      "PARTY_LAST_NAME" = pm4ml_config.PARTY_LAST_NAME
      "PARTY_FIRST_NAME" = pm4ml_config.PARTY_FIRST_NAME
      "PARTY_MIDDLE_NAME" = pm4ml_config.PARTY_MIDDLE_NAME
      "PARTY_DOB" = pm4ml_config.PARTY_DOB
      "DFSP_PREFIX" = pm4ml_config.DFSP_PREFIX
      "DFSP_P2P_PREFIX" = pm4ml_config.DFSP_P2P_PREFIX
      "DFSP_SUB_ID" = pm4ml_config.DFSP_SUB_ID
      "DFSP_TRANSFER_FUNDSIN_AMOUNT" = pm4ml_config.INITIAL_FUNDING_AMOUNT
    }
  ]
}

module "internal_provision_pm4ml_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v2.0.0"
  extgw_fqdn        = "extgw-mgmt-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  token_extgw_fqdn  = "extgw-data-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  extgw_token_service_port = 443
  extgw_admin_port = 443
  test_user_details = local.internal_pm4ml_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

module "provision_pm4ml_callbacks_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/callbacks-post-config?ref=v2.0.0"
  intgw_fqdn        = "intgw-mgmt-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  intgw_token_fqdn  = "intgw-data-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  intgw_rest_port   = 443
  intgw_token_port  = 443
  test_user_details = local.internal_pm4ml_details
  fspiop_version    = split(".", var.helm_mojaloop_version)[0] == "10" ? "1.0" : "1.1"
  user              = "admin"
  password          = local.wso2_admin_pw
}