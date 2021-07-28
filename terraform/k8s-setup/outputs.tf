output "wso2_init_root_cert" {
  value     = module.wso2_init.root_certificate
  sensitive = true
}

output "iskm_cert" {
  value     = module.iskm.iskm_cert
  sensitive = true
}

output "fsp_whitelist_secret_name" {
  value = "${var.whitelist_secret_name_prefix}_fsps"
}
output "pm4ml_whitelist_secret_name" {
  value = "${var.whitelist_secret_name_prefix}_pm4mls"
}
output "sim_whitelist_secret_name" {
  value = "${var.whitelist_secret_name_prefix}_sims"
}
output "sim_onboarding_secret_name" {
  value = "${var.onboarding_secret_name_prefix}_sims"
}
output "pm4ml_onboarding_secret_name" {
  value = "${var.onboarding_secret_name_prefix}_pm4mls"
}
output "fsp_onboarding_secret_name" {
  value = "${var.onboarding_secret_name_prefix}_fsps"
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

output "haproxy_extgw_cert" {
  value       = "${vault_pki_secret_backend_cert.extgw.certificate}\n${vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate}\n${tls_self_signed_cert.ca_cert.cert_pem}"
  sensitive   = true
  description = "cert chain that haproxy advertises for ssl offloading for extgw"
}

output "finance_portal_users" {
  value       = {
    for user in var.finance_portal_users:
    user.username => {
      username           = user.username
      user_pass          = vault_generic_secret.finance_portal_user_password[user.username].data.value
    }
  }
  sensitive   = true
  description = "fin portal users"
}

output "finance-portal-url" {
  description = "URL for the private endpoint for the fin portal ingress."
  value = "finance-portal-v2.${var.environment}.${var.client}.${data.terraform_remote_state.tenant.outputs.domain}.internal:30000"
}