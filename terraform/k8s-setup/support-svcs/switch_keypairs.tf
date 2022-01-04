resource "vault_generic_secret" "jws_switch_public" {
  path = "secret/jws/switch/public"

  data_json = jsonencode({
    "key" = replace(module.intgw.jws_key, "\n", "\\n")
  })
}