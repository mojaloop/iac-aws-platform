resource "helm_release" "redis" {
  for_each         = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.redis_data != null }
  name             = each.value.resource_name
  repository       = each.value.local_resource.resource_helm_repo
  chart            = each.value.local_resource.resource_helm_chart
  version          = each.value.local_resource.resource_helm_chart_version
  namespace        = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
  create_namespace = false
  values = [
    templatefile("${path.module}/templates/${each.value.local_resource.resource_helm_values_ref}", {
      existing_secret     = each.value.local_resource.redis_data.existing_secret == null ? "" : each.value.local_resource.redis_data.existing_secret
      existing_secret_key = each.value.local_resource.redis_data.password_secret_key == null ? "" : each.value.local_resource.redis_data.password_secret_key
      storage_size        = each.value.local_resource.redis_data.storage_size
      auth_enabled        = each.value.local_resource.redis_data.auth_enabled
      storage_class_name  = var.storage_class_name
      name_override       = each.value.resource_name
      service_port        = each.value.local_resource.redis_data.service_port
      architecture        = each.value.local_resource.redis_data.architecture
      replica_count       = each.value.local_resource.redis_data.replica_count
    })
  ]
  provider = helm.helm-main
  depends_on = [
    helm_release.vault_cr_vaultsecret
  ]
}
