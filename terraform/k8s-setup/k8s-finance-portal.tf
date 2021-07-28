resource "helm_release" "finance-portal" {
  name       = "finance-portal"
  repository = "https://docs.mojaloop.io/finance-portal-v2-ui"
  chart      = "finance-portal-v2-ui"
  version    = var.helm_finance_portal_version
  namespace  = "mojaloop"
  timeout    = 800

  values = [
    templatefile("${path.module}/templates/values-finance-portal.yaml.tpl", {
      private_registry_pw = var.ghcr_private_registry_pw,
      private_registry_user = var.ghcr_private_registry_user,
      private_registry_reg = var.ghcr_private_registry_reg,
      image_tag = var.helm_finance_portal_version,
      fin_portal_backend_svc = "mojaloop-finance-portal.mojaloop.svc.cluster.local:3000"
      ingress_host        = "finance-portal-v2.${var.environment}.${var.client}.${data.terraform_remote_state.tenant.outputs.domain}.internal"
      mojaloop_release    = helm_release.mojaloop.name
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}
