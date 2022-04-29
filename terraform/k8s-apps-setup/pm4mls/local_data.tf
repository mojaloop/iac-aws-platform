locals {
  wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
}

data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}