resource "vault_mount" "pki_int" {
  type                      = "pki"
  path                      = "pki-int-ca-${var.name}"
  default_lease_ttl_seconds = 63072000 # 2 years
  max_lease_ttl_seconds     = 63072000 # 2 years
  description               = "Intermediate Authority for sdk ${var.name} in ${local.fqdn}"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  backend            = vault_mount.pki_int.path
  type               = "internal"
  common_name        = "${local.fqdn} Intermediate CA"
  format             = "pem"
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = "4096"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend              = var.vault_root_path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "${local.fqdn} Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = "Infrastructure Team"
  organization         = "Infra"
  ttl                  = 252288000 #8 years
}

resource "local_file" "signed_intermediate" {
  sensitive_content = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
  filename          = "${path.root}/output/int_ca/int_${local.fqdn}_cert.pem"
  file_permission   = "0400"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${var.ca_cert_cert_pem}"
}
