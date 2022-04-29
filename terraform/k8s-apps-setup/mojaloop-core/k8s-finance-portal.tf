resource "helm_release" "finance-portal" {
  name       = "finance-portal"
  repository = "https://mojaloop.github.io/finance-portal-v2-ui"
  chart      = "finance-portal-v2-ui"
  version    = var.helm_finance_portal_version
  namespace  = "mojaloop"
  timeout    = 500

  values = [
    templatefile("${path.module}/templates/values-finance-portal.yaml.tpl", {
      image_tag = var.helm_finance_portal_version,
      fin_portal_backend_svc = "mojaloop-finance-portal.mojaloop.svc.cluster.local:3000"
      ingress_host        = "finance-portal-v2.${dependency.baseinfra.outputs.public_subdomain}"
      mojaloop_release    = helm_release.mojaloop.name
    })
  ]
  provider = helm.helm-main
  depends_on = [helm_release.mojaloop]
}
