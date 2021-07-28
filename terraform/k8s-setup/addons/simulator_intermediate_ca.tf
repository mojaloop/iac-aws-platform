########################################
#  SIMULATORS
#######################################
resource "vault_mount" "pki_int_simulators" {
  for_each                  = toset(var.simulator_names)
  type                      = "pki"
  path                      = "pki-int-ca-${each.value}"
  default_lease_ttl_seconds = 63072000 # 2 years
  max_lease_ttl_seconds     = 63072000 # 2 years
  description               = "Intermediate Authority for simulators Sim ${each.value} in ${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_simulators" {

  for_each           = toset(var.simulator_names)
  backend            = vault_mount.pki_int_simulators[each.value].path
  type               = "internal"
  common_name        = "${each.value}.${data.terraform_remote_state.infrastructure.outputs.private_subdomain} ${each.value} Intermediate CA"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = "4096"

  depends_on = [vault_mount.pki_int_simulators]
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate_simulators" {

  for_each             = toset(var.simulator_names)
  backend              = data.terraform_remote_state.k8s-base.outputs.vault_root_path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate_simulators[each.value].csr
  common_name          = "${each.value}.${data.terraform_remote_state.infrastructure.outputs.private_subdomain} ${each.value} Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = "Infrastructure Team"
  organization         = "ModusBox"
  ttl                  = 252288000 #8 years
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.intermediate_simulators]
}

resource local_file signed_intermediate_simulators {
  for_each          = toset(var.simulator_names)
  sensitive_content = vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate
  filename          = "${path.root}/output/int_ca/int_${each.value}_cert.pem"
  file_permission   = "0400"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_simulators" {
  for_each    = toset(var.simulator_names)
  backend     = vault_mount.pki_int_simulators[each.value].path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.intermediate_simulators[each.value].certificate}\n${data.terraform_remote_state.k8s-base.outputs.ca_cert_cert_pem}"
}
