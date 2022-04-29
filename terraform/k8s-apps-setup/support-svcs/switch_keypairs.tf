resource "vault_generic_secret" "jws_switch_public" {
  path = "secret/mcm/dfsp-jws-certs/0"
  data_json = jsonencode({
    "dfspId" = "switch"
    "publicKey" = module.intgw.jws_key
    "validationState" = "VALID"
  })
}