
resource "helm_release" "publicapi" {
  name       = "publicapi"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "oathkeeper"
  version    = var.helm_oathkeeper_version
  namespace  = "mojaloop"
  timeout    = 300
  skip_crds  = true

  values = [
    templatefile(split(".", var.k8s_api_version)[1] > 18 ? "${path.module}/templates/values-publicapi.yaml.tpl" : "${path.module}/templates/values-publicapi_pre_1_19.yaml.tpl", {
      publicapi_fqdn = "public-api.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      account_oracle_admin_api_endpoint  = "http://${var.mfi_account_oracle_name}.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}/admin-api",
    })
  ]
  provider = helm.helm-gateway
}
