resource "tls_private_key" "pm4mls" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  algorithm = "RSA"
  rsa_bits  = "4096"
}
resource "tls_self_signed_cert" "pm4mls" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.pm4mls[each.key].private_key_pem

  subject {
    common_name  = each.key
    organization = "ModusBox"
  }

  validity_period_hours = 10000

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "vault_generic_secret" "jws_pm4mls_certificate" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  path     = "secret/jws/pm4mls/${each.key}/certificate"

  data_json = jsonencode({
    "key" = replace(tls_self_signed_cert.pm4mls[each.key].cert_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_pm4mls_private" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  path     = "secret/jws/pm4mls/${each.key}/private"

  data_json = jsonencode({
    "key" = replace(tls_private_key.pm4mls[each.key].private_key_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_pm4mls_public" {
  for_each    = {for pm4ml_config in var.internal_pm4ml_configs: pm4ml_config.DFSP_NAME => pm4ml_config}
  path     = "secret/jws/pm4mls/${each.key}/public"

  data_json = jsonencode({
    "key" = replace(tls_private_key.pm4mls[each.key].public_key_pem, "\n", "\\n")
  })
}
