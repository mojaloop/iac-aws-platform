resource "helm_release" "mojaloop-reporting" {
  name         = "mojaloop-reporting"
  repository   = "https://raw.githubusercontent.com/mojaloop/reporting/repo"
  chart        = "reporting-service"
  namespace    = "mojaloop"
  version      = var.helm_mojaloop_reporting_service_version

  values = [
    templatefile("${path.module}/templates/values-reporting.yaml.tpl", {
      db_password = vault_generic_secret.mojaloop_mysql_password.data.value,
      db_user = "central_ledger",
      db_host = "${var.helm_mojaloop_release_name}-centralledger-mysql",
      ingress_host  = "mojaloop-reporting.${var.environment}.${var.client}.${data.terraform_remote_state.tenant.outputs.domain}.internal"
    })
  ]

  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}  