resource "tls_private_key" "sdk" {
  for_each  = { for sdk in var.sdks : sdk.name => sdk.name }
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "sdks" {
  for_each        = { for sdk in var.sdks : sdk.name => sdk.name }
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.sdk[each.value].private_key_pem

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

resource "local_file" "jws_public_keys_sdk" {
  for_each        = { for sdk in var.sdks : sdk.name => sdk.name }
  content         = tls_private_key.sdk[each.value].public_key_pem
  filename        = "${path.root}/sdk_certs/${each.value}/jwsVerificationCerts/${each.value}.pem"
  file_permission = "0644"
}

resource "local_file" "jws_private_key_sdk" {
  for_each          = { for sdk in var.sdks : sdk.name => sdk.name }
  sensitive_content = tls_private_key.sdk[each.value].private_key_pem
  filename          = "${path.root}/sdk_certs/${each.value}/jwsSigningKey/private.key"
  file_permission   = "0644"
}

locals {
  switch_pem = map("switch.pem", data.terraform_remote_state.k8s-base.outputs.switch_jws_key)
  non_resp   = map("noresponsepayeefsp.pem", tls_private_key.simulators["payeefsp"].public_key_pem)
  sim_pem    = { for value in toset(var.simulator_names) : "${value}.pem" => tls_private_key.simulators[value].public_key_pem }
  sdk_pem    = { for sdk in var.sdks : "${sdk.name}.pem" => tls_private_key.sdk[sdk.name].public_key_pem }
  jws_pub    = merge(local.switch_pem, local.non_resp, local.sim_pem, local.sdk_pem)
}

resource "local_file" "sdk_jws_all_public_keys" {
  content         = jsonencode(local.jws_pub)
  filename        = "${path.root}/sdk_certs/all_public_jws_keys.json"
  file_permission = "0644"
}

resource "vault_generic_secret" "jws_sdks_certificate" {
  for_each = { for sdk in var.sdks : sdk.name => sdk.name }
  path     = "secret/jws/sdks/${each.value}/certificate"

  data_json = jsonencode({
    "key" = replace(tls_self_signed_cert.sdks[each.value].cert_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_sdks_private" {
  for_each = { for sdk in var.sdks : sdk.name => sdk.name }
  path     = "secret/jws/sdks/${each.value}/private"

  data_json = jsonencode({
    "key" = replace(tls_private_key.sdk[each.value].private_key_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_sdks_public" {
  for_each = { for sdk in var.sdks : sdk.name => sdk.name }
  path     = "secret/jws/sdks/${each.value}/public"

  data_json = jsonencode({
    "key" = replace(tls_private_key.sdk[each.value].public_key_pem, "\n", "\\n")
  })
}
