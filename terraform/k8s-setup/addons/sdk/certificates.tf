resource "vault_pki_secret_backend_cert" "server" {
  backend     = vault_mount.pki_int.path
  name        = vault_pki_secret_backend_role.server.name
  common_name = local.fqdn
  depends_on  = [vault_pki_secret_backend_role.server, vault_pki_secret_backend_intermediate_set_signed.intermediate]
}

resource "vault_pki_secret_backend_cert" "switch_client" {
  backend     = vault_mount.pki_int.path
  name        = vault_pki_secret_backend_role.client.name
  common_name = local.fqdn
  depends_on  = [vault_pki_secret_backend_intermediate_set_signed.intermediate]
}

resource "vault_pki_secret_backend_cert" "personal_client" {
  backend     = vault_mount.pki_int.path
  name        = vault_pki_secret_backend_role.client.name
  common_name = local.fqdn
  depends_on  = [vault_pki_secret_backend_role.client, vault_pki_secret_backend_intermediate_set_signed.intermediate]
}
