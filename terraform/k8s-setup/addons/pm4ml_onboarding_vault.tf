resource "vault_generic_secret" "int_pm4ml_onboarding_data" {
for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  path      = "${data.terraform_remote_state.k8s-base.outputs.pm4ml_onboarding_secret_name}/${each.key}"
  disable_read = false
  data_json = jsonencode({
     "client_cert_chain" = "${data.local_file.pm4ml_client_key[each.key].content}\n${data.local_file.pm4ml_client_cert[each.key].content}"
     "ca_bundle" = data.local_file.pm4ml_ca[each.key].content
     "host"     = each.key
     "fqdn"     = "connector.${each.key}.${replace(var.client, "-", "")}${replace(var.environment, "-", "")}k3s.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  })
}

data "local_file" "pm4ml_client_cert" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  filename = "${path.module}/pm4ml-certoutput/${each.key}-client-cert.pem"
}
data "local_file" "pm4ml_client_key" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  filename = "${path.module}/pm4ml-certoutput/${each.key}-client-key.pem"
}
data "local_file" "pm4ml_ca" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  filename = "${path.module}/pm4ml-certoutput/${each.key}-ca-cert.pem"
}

resource "vault_generic_secret" "ext_pm4ml_onboarding_data" {
  for_each  =  yamldecode(fileexists("${path.module}/ext-pm4ml-certs.yaml") ? file("${path.module}/ext-pm4ml-certs.yaml") : "{}")
  path      = "${data.terraform_remote_state.k8s-base.outputs.fsp_onboarding_secret_name}/${each.key}"
  disable_read = false
  data_json = jsonencode(
    (lookup(each.value, "mtls_disabled", null) != null) ? {
      "client_cert_chain" = "${each.value.tls_outbound_privkey}\n${each.value.tls_outbound_clientcert}"
      "ca_bundle" = each.value.tls_outbound_cacert
      "host"     = each.key
      "fqdn"     = each.value.callback_url
      "mtls_disabled" = each.value.mtls_disabled
    } :
    {
      "client_cert_chain" = "${each.value.tls_outbound_privkey}\n${each.value.tls_outbound_clientcert}"
      "ca_bundle" = each.value.tls_outbound_cacert
      "host"     = each.key
      "fqdn"     = each.value.callback_url
    }
  )
}