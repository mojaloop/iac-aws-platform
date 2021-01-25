output "wso2_init_root_cert" {
  value     = module.wso2_init.root_certificate
  sensitive = true
}

output "iskm_cert" {
  value     = module.iskm.iskm_cert
  sensitive = true
}

output "whitelist_secret_name" {
  value = "${var.whitelist_secret_name_prefix}_fsp"
}

output "sim_whitelist_secret_name" {
  value = "${var.whitelist_secret_name_prefix}_sims"
}

output "ca_cert_cert_pem" {
  value     = tls_self_signed_cert.ca_cert.cert_pem
  sensitive = true
}

output "vault_root_path" {
  value = vault_mount.root.path
}

output "vault_pki_int_path" {
  value = vault_mount.pki_int.path
}


output "root_signed_intermediate_certificate" {
  value     = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
  sensitive = true
}

output "vault_role_client_cert_name" {
  value     = vault_pki_secret_backend_role.role-client-cert.name
  sensitive = true
}

output "root_signed_intermediate_ca_cert_chain" {
  value     = "${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
  sensitive = true
}

output "intermediate_key" {
  value     = "${vault_pki_secret_backend_intermediate_cert_request.intermediate.private_key}"
  sensitive = true
}

output "haproxy_iskm_cert" {
  value       = "${vault_pki_secret_backend_cert.iskm.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
  sensitive   = true
  description = "cert chain that haproxy advertises for ssl offloading"
}

output "helm_mojaloop_version" {
  value       = var.helm_mojaloop_version
  description = "Helm Mojaloop Version"
}

output "switch_jws_key" {
  description = "switch JWS key"
  value       = module.intgw.jws_key
}
