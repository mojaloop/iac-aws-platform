locals {
  internal_pm4ml_whitelist = {
    for pm4ml_config in var.internal_pm4ml_configs :
    pm4ml_config.DFSP_NAME => join(",", [for natip in var.pm4ml_nat_ips : "${natip}/32"])
  }
  external_pm4ml_whitelist = {
    for k, v in yamldecode(fileexists("${path.module}/ext-pm4ml-certs.yaml") ? file("${path.module}/ext-pm4ml-certs.yaml") : "{\"dummyfsp\": { \"nat_ips\":  \"127.0.0.1/32\" } }") :
    k => v.nat_ips
  }
}

resource "vault_generic_secret" "internal_pm4ml_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.pm4ml_whitelist_secret_name
  data_json = jsonencode(local.internal_pm4ml_whitelist)
}

resource "vault_generic_secret" "fsp_whitelist" {
  path      = data.terraform_remote_state.k8s-base.outputs.fsp_whitelist_secret_name
  data_json = jsonencode(local.external_pm4ml_whitelist)
}
