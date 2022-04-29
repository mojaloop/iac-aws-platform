
resource "local_file" "gen_ext_ansible_output" {
  content         = yamlencode(local.external_pm4ml_output)
  filename        = "${path.root}/ansible_external_pm4ml_output.yaml"
  file_permission = "0644"
}

resource "local_file" "gen_ext_postman_output" {
  content         = jsonencode(local.external_postman_pm4ml_output)
  filename        = "${path.root}/onboarding_external_pm4ml_output.json"
  file_permission = "0644"
}

locals {
  external_pm4ml_details = {
    for pm4ml_config in var.external_pm4ml_configs :
    pm4ml_config.DFSP_NAME => {
      sim_name              = pm4ml_config.DFSP_NAME
      sim_password          = "${pm4ml_config.DFSP_NAME}123"
      sim_callback_url      = "https://haproxy-callback.wso2.svc.cluster.local/fsp/${pm4ml_config.DFSP_NAME}/inbound"
      subscribe_to_api_list = "FSPIOP"
    }
  }
  external_pm4ml_output = {
    for pm4ml_config in var.external_pm4ml_configs :
    pm4ml_config.DFSP_NAME => {      
      "pm4ml_instance_name"  = pm4ml_config.DFSP_NAME
      "pm4ml_subdomain"      = pm4ml_config.DFSP_SUBDOMAIN
      "mcm_auth_enabled"     = true
      "mcm_auth_user"        = pm4ml_config.DFSP_NAME
      "mcm_auth_pass"        = "${pm4ml_config.DFSP_NAME}123"
      "dfsp_id"              = pm4ml_config.DFSP_NAME
      "extgw_fqdn"           = "extgw-data.${dependency.baseinfra.outputs.public_subdomain}"
      "mcm_host_url"         = "mcm.${dependency.baseinfra.outputs.public_subdomain}"
      "helm_release_name"    = pm4ml_config.DFSP_NAME
      "ttk_enabled"          = false
      "extgw_client_key"     = module.external_provision_pm4ml_to_wso2.client-ids[pm4ml_config.DFSP_NAME]
      "extgw_client_secret"  = module.external_provision_pm4ml_to_wso2.client-secrets[pm4ml_config.DFSP_NAME]
      "OAUTH_TOKEN_ENDPOINT" = "https://extgw-data.${dependency.baseinfra.outputs.public_subdomain}:443/oauth2/token"
    }
  }
  external_postman_pm4ml_output = [
    for pm4ml_config in var.external_pm4ml_configs :
    {
      "DFSP_NAME" = pm4ml_config.DFSP_NAME
      "DFSP_PREFIX" = pm4ml_config.DFSP_PREFIX
      "DFSP_CURRENCY" = pm4ml_config.DFSP_CURRENCY
      "GENERIC_DFSP_CALLBACK_URL" = "https://intgw-data-int.${dependency.baseinfra.outputs.public_subdomain}:443/${pm4ml_config.DFSP_NAME}/1.0"
      "DFSP_NOTIFICATION_EMAIL" = pm4ml_config.DFSP_NOTIFICATION_EMAIL
    }
  ]

}

module "external_provision_pm4ml_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v2.0.0"
  extgw_fqdn        = "extgw-mgmt-int.${dependency.baseinfra.outputs.public_subdomain}"
  token_extgw_fqdn  = "extgw-data-int.${dependency.baseinfra.outputs.public_subdomain}"
  extgw_token_service_port = 443
  extgw_admin_port = 443
  test_user_details = local.external_pm4ml_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

module "external_provision_pm4ml_callbacks_to_wso2" {
  source            = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/callbacks-post-config?ref=v2.0.0"
  intgw_fqdn        = "intgw-mgmt-int.${dependency.baseinfra.outputs.public_subdomain}"
  intgw_token_fqdn  = "intgw-data-int.${dependency.baseinfra.outputs.public_subdomain}"
  intgw_rest_port   = 443
  intgw_token_port  = 443
  test_user_details = local.external_pm4ml_details
  fspiop_version    = split(".", var.helm_mojaloop_version)[0] == "10" ? "1.0" : "1.1"
  user              = "admin"
  password          = local.wso2_admin_pw
}