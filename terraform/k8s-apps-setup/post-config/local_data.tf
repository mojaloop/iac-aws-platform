locals {
  wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
  switch_pem = tomap({
                  "switch.pem" = var.switch_jws_key
                })

  jws_pub    = local.switch_pem
}

data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}