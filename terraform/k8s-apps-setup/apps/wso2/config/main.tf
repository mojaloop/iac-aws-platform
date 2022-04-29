data "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"
}

resource "ansible_host" "api_publisher" {
  inventory_hostname = "localhost"
  vars = {
    external_domain = dependency.baseinfra.outputs.public_subdomain
    internal_domain = dependency.baseinfra.outputs.private_subdomain
    ml_version = "v${dependency.mojaloopcore.outputs.helm_mojaloop_version}"
    wso2_admin_pw = data.vault_generic_secret.ws02_admin_password.data.value
  }
}
