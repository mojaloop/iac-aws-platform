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
      ingress_host  = "mojaloop-reporting.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}  