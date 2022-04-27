provider "restapi" {
  alias                = "restapi_mcm"
  uri                  = "https://${var.mcm_name}.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  debug                = true
  write_returns_object = false
  create_returns_object = true

  oauth_client_credentials {
    oauth_client_id = data.terraform_remote_state.support-svcs.outputs.mcm_portal_client_id
    oauth_client_secret = data.terraform_remote_state.support-svcs.outputs.mcm_portal_client_secret
    oauth_token_endpoint = "https://iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}:443/oauth2/token"
    oauth_scopes = ["openid"]
  }
}

resource "restapi_object" "pm4ml_account" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs : pm4ml_config.DFSP_NAME => pm4ml_config}
  provider = restapi.restapi_mcm
  path = "/api/dfsps"
  debug                = true
  data = "{ \"dfspId\": \"${each.key}\", \"name\": \"${each.key}\", \"monetaryZoneId\": \"${each.value.DFSP_CURRENCY}\" }"

  read_path = "/api/dfsps"
  read_search = {
    id = "${each.key}"
    id_attribute = "id"
    search_path = "/api/dfsps"
    search_key = "id"
    search_value = "${each.key}"
  }
  destroy_method = "GET"
  destroy_path = "/api/dfsps"
}
