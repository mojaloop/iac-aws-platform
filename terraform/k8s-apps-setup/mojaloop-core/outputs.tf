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
output "helm_mojaloop_version" {
  value       = var.helm_mojaloop_version
  description = "Helm Mojaloop Version"
}
