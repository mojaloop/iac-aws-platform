resource "tls_private_key" "switch" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "vault_generic_secret" "jws_switch_private" {
  path = "secret/jws/switch/private"

  data_json = jsonencode({
    "key" = replace(tls_private_key.switch.private_key_pem, "\n", "\\n")
  })
}

resource "vault_generic_secret" "jws_switch_public" {
  path = "secret/jws/switch/public"

  data_json = jsonencode({
    "key" = replace(tls_private_key.switch.public_key_pem, "\n", "\\n")
  })
}
