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
output "vault_root_path" {
  value = vault_mount.root.path
}

output "vault_role_client_cert_name" {
  value     = vault_pki_secret_backend_role.role-client-cert.name
  sensitive = true
}

output "switch_jws_key" {
  description = "switch JWS key"
  value       = module.intgw.jws_key
}

output "switch_jws_private_key" {
  description = "switch JWS priv key"
  value       = module.intgw.jws_private_key
  sensitive = true
}

output "mcm_portal_client_id" {
  description = "client id for mcm portal"
  value       = module.mcm-iskm-key-secret-gen.mcm-key
  sensitive = true
}

output "mcm_portal_client_secret" {
  description = "client secret for mcm portal"
  value       = module.mcm-iskm-key-secret-gen.mcm-secret
  sensitive = true
}