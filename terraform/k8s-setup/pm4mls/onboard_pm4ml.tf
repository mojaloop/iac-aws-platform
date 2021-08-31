
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
      sim_callback_url      = "https://${data.terraform_remote_state.infrastructure.outputs.haproxy_callback_private_fqdn}/sim/${pm4ml_config.DFSP_NAME}/inbound"
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
      "private_reg_user"     = "mbx-cicd-deployer"
      "private_reg_pass"     = var.private_registry_pw
      "private_reg_url"      = "modusbox-mbx-docker.jfrog.io"
      "dfsp_id"              = pm4ml_config.DFSP_NAME
      "extgw_fqdn"           = "extgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
      "mcm_host_url"         = data.terraform_remote_state.infrastructure.outputs.mcm_fqdn
      "p12_pass_phrase"       = "samplepass"
      "ml_connector_image_tag" = "12.0.4"
      "helm_release_name"    = pm4ml_config.DFSP_NAME
      "ttk_enabled"          = false
      "extgw_client_key"     = module.internal_provision_pm4ml_to_wso2.client-ids[pm4ml_config.DFSP_NAME]
      "extgw_client_secret"  = module.internal_provision_pm4ml_to_wso2.client-secrets[pm4ml_config.DFSP_NAME]
      "OAUTH_TOKEN_ENDPOINT" = "https://${data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn}:9443/oauth2/token"
      "tls_outbound_cacert"  = data.terraform_remote_state.k8s-base.outputs.root_signed_intermediate_ca_cert_chain
      "tls_outbound_privkey" = vault_pki_secret_backend_cert.internal-switch-pm4ml-client[pm4ml_config.DFSP_NAME].private_key
      "tls_outbound_cert"    = vault_pki_secret_backend_cert.internal-switch-pm4ml-client[pm4ml_config.DFSP_NAME].certificate
      "jws_private_key"      = tls_private_key.pm4mls[pm4ml_config.DFSP_NAME].private_key_pem
      "jws_public_keys"      = { for pm4ml_config2 in var.internal_pm4ml_configs : pm4ml_config2.DFSP_NAME => tls_private_key.pm4mls[pm4ml_config2.DFSP_NAME].public_key_pem }
    }
  }
  internal_postman_pm4ml_output = [
    for pm4ml_config in var.internal_pm4ml_configs :
    {
      "DFSP_NAME" = pm4ml_config.DFSP_NAME
      "DFSP_CURRENCY" = pm4ml_config.DFSP_CURRENCY
      "DFSP_MSISDN" = pm4ml_config.DFSP_MSISDN
      "GENERIC_DFSP_CALLBACK_URL" = "http://${data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn}:8844/${pm4ml_config.DFSP_NAME}/1.0"
      "GENERIC_DFSP_BACKEND_TESTAPI_URL" = "http://test.${pm4ml_config.DFSP_NAME}.${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}/sim-backend-test"
      "DFSP_ACCOUNT_ID" = pm4ml_config.DFSP_ACCOUNT_ID
      "DFSP_NOTIFICATION_EMAIL" = pm4ml_config.DFSP_NOTIFICATION_EMAIL
      "PARTY_FULL_NAME" = "${pm4ml_config.PARTY_FIRST_NAME} ${pm4ml_config.PARTY_LAST_NAME}"
      "PARTY_LAST_NAME" = pm4ml_config.PARTY_LAST_NAME
      "PARTY_FIRST_NAME" = pm4ml_config.PARTY_FIRST_NAME
      "PARTY_MIDDLE_NAME" = pm4ml_config.PARTY_MIDDLE_NAME
      "PARTY_DOB" = pm4ml_config.PARTY_DOB
      "DFSP_PREFIX" = pm4ml_config.DFSP_PREFIX
    }
  ]
}

resource "local_file" "pm4ml_personal_client_certificate" {
  for_each        = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  content         = vault_pki_secret_backend_cert.internal-switch-pm4ml-client[each.value.DFSP_NAME].certificate
  filename        = "${path.root}/secrets_chart/${each.value.DFSP_NAME}/tls/${each.value.DFSP_NAME}_client.crt"
  file_permission = "0644"
}

resource "local_file" "pm4ml_personal_client_key" {
  for_each          = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  sensitive_content = vault_pki_secret_backend_cert.internal-switch-pm4ml-client[each.value.DFSP_NAME].private_key
  filename          = "${path.root}/secrets_chart/${each.value.DFSP_NAME}/tls/${each.value.DFSP_NAME}_client.key"
  file_permission   = "0644"
}

module "internal_provision_pm4ml_to_wso2" {
  source            = "git::git::https://github.com/mojaloop/iac-shared-modules.git//wso2/create-test-user?ref=v1.0.19"
  extgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  test_user_details = local.internal_pm4ml_details
  admin_user        = "admin"
  admin_password    = local.wso2_admin_pw
}

module "provision_pm4ml_callbacks_to_wso2" {
  source            = "git::git::https://github.com/mojaloop/iac-shared-modules.git//wso2/callbacks-post-config?ref=v1.0.19"
  intgw_fqdn        = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  test_user_details = local.internal_pm4ml_details
  fspiop_version    = split(".", var.helm_mojaloop_version)[0] == "10" ? "1.0" : "1.1"
  user              = "admin"
  password          = local.wso2_admin_pw
}
#this should go away once automation via mcm is done.
resource "vault_pki_secret_backend_cert" "internal-switch-pm4ml-client" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  backend     = data.terraform_remote_state.k8s-base.outputs.vault_pki_int_path
  name        = data.terraform_remote_state.k8s-base.outputs.vault_role_client_cert_name
  common_name = "${each.value.DFSP_NAME}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
}

output "switch_routing_table_ids" {
  value       = var.helm_mojaloop_version
  description = "Helm Mojaloop Version"
} 
