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
