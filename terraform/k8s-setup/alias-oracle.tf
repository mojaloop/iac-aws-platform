resource "aws_route53_record" "alias-oracle-gateway-private" {
  count   = var.use_alias_oracle_endpoint == "yes" ? 1 : 0
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.alias_oracle_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}

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
      private_registry_pw = var.ghcr_private_registry_pw,
      private_registry_repo = var.ghcr_private_registry_reg
      private_registry_user = var.ghcr_private_registry_user
      ingress_host        = aws_route53_record.alias-oracle-gateway-private[0].fqdn
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

output "alias-oracle-fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value = var.use_alias_oracle_endpoint == "yes" ? aws_route53_record.alias-oracle-gateway-private[0].fqdn : "not used"
}