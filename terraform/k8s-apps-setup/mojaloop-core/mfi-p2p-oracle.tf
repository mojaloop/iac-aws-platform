resource "helm_release" "mfi-p2p-oracle" {
  count      = var.use_mfi_p2p_oracle_endpoint == "yes" ? 1 : 0
  name       = "mfi-p2p-oracle"
  repository = "https://mojaloop.github.io/mfi-account-oracle"
  chart      = "mfi-account-oracle"
  version    = var.helm_mfi_p2p_oracle_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-mfi-p2p-oracle.yaml.tpl", {
      ingress_host = "${var.mfi_p2p_oracle_name}.${dependency.baseinfra.outputs.public_subdomain}"
      storage_class = var.storage_class_name
      service_name = var.mfi_p2p_oracle_name
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop]
}

output "mfi-p2p-oracle-fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value = var.use_mfi_p2p_oracle_endpoint == "yes" ? "${var.mfi_p2p_oracle_name}.${dependency.baseinfra.outputs.public_subdomain}" : "not used"
}
