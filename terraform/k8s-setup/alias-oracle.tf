resource "helm_release" "alias-oracle" {
  count      = var.use_alias_oracle_endpoint == "yes" ? 1 : 0
  name       = "alias-oracle"
  repository = "https://docs.mojaloop.io/alias-oracle"
  chart      = "alias-oracle"
  version    = var.helm_alias_oracle_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-alias-oracle.yaml.tpl", {
      ingress_host = "${var.alias_oracle_name}.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}"
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

output "alias-oracle-fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value = var.use_alias_oracle_endpoint == "yes" ? "${var.alias_oracle_name}.${data.terraform_remote_state.infrastructure.outputs.private_subdomain}" : "not used"
}