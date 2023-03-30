resource "helm_release" "mongodb" {
  for_each         = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.mongodb_data != null }
  name             = each.value.resource_name
  repository       = each.value.local_resource.resource_helm_repo
  chart            = each.value.local_resource.resource_helm_chart
  version          = each.value.local_resource.resource_helm_chart_version
  namespace        = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
  create_namespace = false
  values = [
    templatefile("${path.module}/templates/${each.value.local_resource.resource_helm_values_ref}", {
      password           = ""
      root_password      = ""
      existing_secret    = each.value.local_resource.mongodb_data.existing_secret
      database_user      = each.value.local_resource.mongodb_data.user
      database_name      = each.value.local_resource.mongodb_data.database_name
      storage_size       = each.value.local_resource.mongodb_data.storage_size
      storage_class_name = var.storage_class_name
      name_override      = each.value.resource_name
      service_port       = each.value.local_resource.mongodb_data.service_port
    })
  ]
  provider = helm.helm-main
  depends_on = [
    helm_release.vault_cr_vaultsecret
  ]
}
