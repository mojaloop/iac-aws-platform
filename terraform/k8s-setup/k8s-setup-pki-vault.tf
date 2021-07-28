resource "vault_mount" "pki_int" {
  type                      = "pki"
  path                      = "pki-int-ca"
  default_lease_ttl_seconds = 63072000 # 2 years
  max_lease_ttl_seconds     = 63072000 # 2 years
  description               = "Intermediate Authority for ${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on = [vault_mount.pki_int]

  backend            = vault_mount.pki_int.path
  type               = "internal"
  common_name        = "${data.terraform_remote_state.infrastructure.outputs.private_subdomain} Intermediate CA"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = "4096"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  depends_on = [vault_pki_secret_backend_intermediate_cert_request.intermediate, vault_pki_secret_backend_config_ca.ca_config]
  backend    = vault_mount.root.path

  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "${data.terraform_remote_state.infrastructure.outputs.private_subdomain} Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = "Infrastructure Team"
  organization         = "ModusBox"
  ttl                  = 252288000 #8 years

}
resource local_file signed_intermediate {
  sensitive_content = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
  filename          = "${path.root}/output/int_ca/int_cert.pem"
  file_permission   = "0400"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend = vault_mount.pki_int.path

  certificate = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
}

resource "vault_pki_secret_backend_role" "role-server-cert" {
  backend            = vault_mount.pki_int.path
  name               = "server-cert-role"
  allowed_domains    = [trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, "."), trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = true
  client_flag        = false
  ou                 = ["Infrastructure Team"]
  organization       = ["ModusBox"]
  key_bits           = 4096
  # 2 years
  max_ttl  = 63113904
  ttl      = 63113904
  no_store = true
}

resource "vault_pki_secret_backend_role" "role-client-cert" {
  backend            = vault_mount.pki_int.path
  name               = "client-cert-role"
  allowed_domains    = [data.terraform_remote_state.infrastructure.outputs.private_subdomain, trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")]
  allow_subdomains   = true
  allow_glob_domains = false
  allow_bare_domains = true # needed for email address verification
  allow_any_name     = false
  enforce_hostnames  = true
  allow_ip_sans      = true
  server_flag        = false
  client_flag        = true
  ou                 = ["Infrastructure Team"]
  organization       = ["ModusBox"]
  key_bits           = 4096
  # 2 years
  max_ttl  = 63113904
  ttl      = 63113904
  no_store = true
}

resource "vault_pki_secret_backend_cert" "extgw" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "extgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.public_subdomain, ".")}"
}

resource "vault_pki_secret_backend_cert" "intgw" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "intgw.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, ".")}"
}

resource "vault_pki_secret_backend_cert" "iskm" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "iskm.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, ".")}"
}

resource "vault_pki_secret_backend_cert" "haproxy-callback-cert" {
  depends_on = [vault_pki_secret_backend_role.role-server-cert, vault_pki_secret_backend_intermediate_set_signed.intermediate]

  backend = vault_mount.pki_int.path
  name    = vault_pki_secret_backend_role.role-server-cert.name

  common_name = "haproxy-callback.${trimsuffix(data.terraform_remote_state.infrastructure.outputs.private_subdomain, ".")}"
}