resource "vault_pki_secret_backend_cert" "simulators-server" {
  for_each    = toset(var.simulator_names)
  backend     = vault_mount.pki_int_simulators[each.value].path
  name        = vault_pki_secret_backend_role.role-server-cert-simulators[each.value].name
  common_name = "${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
  depends_on  = [vault_pki_secret_backend_role.role-server-cert-simulators, vault_pki_secret_backend_intermediate_set_signed.intermediate_simulators]
}

resource "vault_pki_secret_backend_cert" "switch-simulators-client" {
  for_each    = toset(var.simulator_names)
  backend     = data.terraform_remote_state.k8s-base.outputs.vault_pki_int_path
  name        = data.terraform_remote_state.k8s-base.outputs.vault_role_client_cert_name
  common_name = "${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
  depends_on  = [vault_pki_secret_backend_intermediate_set_signed.intermediate_simulators]
}

resource "vault_pki_secret_backend_cert" "simulators-personal-client" {
  for_each    = toset(var.simulator_names)
  backend     = vault_mount.pki_int_simulators[each.value].path
  name        = vault_pki_secret_backend_role.role-client-cert-simulators[each.value].name
  common_name = "${each.value}.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
  depends_on  = [vault_pki_secret_backend_role.role-client-cert-simulators, vault_pki_secret_backend_intermediate_set_signed.intermediate_simulators]
}
