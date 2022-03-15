resource "helm_release" "mfi-account-oracle" {
  count      = var.use_mfi_account_oracle_endpoint == "yes" ? 1 : 0
  name       = "mfi-account-oracle"
  repository = "https://mojaloop.github.io/mfi-account-oracle"
  chart      = "mfi-account-oracle"
  version    = var.helm_mfi_account_oracle_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-mfi-account-oracle.yaml.tpl", {
      ingress_host = "${var.mfi_account_oracle_name}.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
      storage_class_name = var.storage_class_name
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

output "mfi-account-oracle-fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value = var.use_mfi_account_oracle_endpoint == "yes" ? "${var.mfi_account_oracle_name}.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}" : "not used"
}
