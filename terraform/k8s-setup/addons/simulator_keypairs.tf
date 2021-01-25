resource "tls_private_key" "simulators" {
  for_each  = toset(var.simulator_names)
  algorithm = "RSA"
  rsa_bits  = "4096"
}
resource "tls_self_signed_cert" "simulators" {
  for_each        = toset(var.simulator_names)
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.simulators[each.value].private_key_pem

  subject {
    common_name  = each.value
    organization = "Infra"
  }

  validity_period_hours = 10000

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "vault_generic_secret" "jws_simulators_certificate" {
  for_each = toset(var.simulator_names)
  path     = "secret/jws/simulators/${each.value}/certificate"

  data_json = jsonencode({
    "key" = replace(tls_self_signed_cert.simulators[each.value].cert_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_simulators_private" {
  for_each = toset(var.simulator_names)
  path     = "secret/jws/simulators/${each.value}/private"

  data_json = jsonencode({
    "key" = replace(tls_private_key.simulators[each.value].private_key_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_simulators_public" {
  for_each = toset(var.simulator_names)
  path     = "secret/jws/simulators/${each.value}/public"

  data_json = jsonencode({
    "key" = replace(tls_private_key.simulators[each.value].public_key_pem, "\n", "\\n")
  })
}
