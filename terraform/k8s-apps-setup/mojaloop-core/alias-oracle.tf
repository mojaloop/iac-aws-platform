resource "helm_release" "alias-oracle" {
  count      = var.use_alias_oracle_endpoint == "yes" ? 1 : 0
  name       = "alias-oracle"
  repository = "https://mojaloop.github.io/alias-oracle"
  chart      = "alias-oracle"
  version    = var.helm_alias_oracle_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-alias-oracle.yaml.tpl", {
      ingress_host = "${var.alias_oracle_name}.${dependency.baseinfra.outputs.public_subdomain}"
      storage_class = var.storage_class_name
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop]
}

output "alias-oracle-fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value = var.use_alias_oracle_endpoint == "yes" ? "${var.alias_oracle_name}.${dependency.baseinfra.outputs.public_subdomain}" : "not used"
}