resource "helm_release" "mysql_legacy" {
  for_each         = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.resource_type == "mysql" && stateful_resource.local_resource != null && try(stateful_resource.local_resource.mysql_data.is_legacy, false) }
  name             = each.value.resource_name
  repository       = each.value.local_resource.resource_helm_repo
  chart            = each.value.local_resource.resource_helm_chart
  version          = each.value.local_resource.resource_helm_chart_version
  namespace        = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
  create_namespace = false
  values = [
    templatefile("${path.module}/templates/${each.value.local_resource.resource_helm_values_ref}", {
      password           = vault_generic_secret.mysql[each.key].data.value
      root_password      = vault_generic_secret.mysql-root[each.key].data.value
      database_user      = each.value.local_resource.mysql_data.user
      database_name      = each.value.local_resource.mysql_data.database_name
      storage_size       = each.value.local_resource.mysql_data.storage_size
      storage_class_name = var.storage_class_name
      name_override      = each.value.resource_name
      architecture       = each.value.local_resource.mysql_data.architecture
      replica_count      = each.value.local_resource.mysql_data.replica_count
      service_port       = each.value.local_resource.mysql_data.service_port
    })
  ]
  provider = helm.helm-main
  depends_on = [
    helm_release.vault_secret_manifests
  ]
}

resource "helm_release" "mysql" {
  for_each         = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.resource_type == "mysql" && stateful_resource.local_resource != null && try(!stateful_resource.local_resource.mysql_data.is_legacy, false) }
  name             = each.value.resource_name
  repository       = each.value.local_resource.resource_helm_repo
  chart            = each.value.local_resource.resource_helm_chart
  version          = each.value.local_resource.resource_helm_chart_version
  namespace        = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
  create_namespace = false
  values = [
    templatefile("${path.module}/templates/${each.value.local_resource.resource_helm_values_ref}", {
      existing_secret    = each.value.local_resource.mysql_data.existing_secret == null ? "" : each.value.local_resource.mysql_data.existing_secret
      password           = each.value.local_resource.mysql_data.existing_secret == null ? vault_generic_secret.mysql[each.key].data.value : ""
      root_password      = each.value.local_resource.mysql_data.existing_secret == null ? vault_generic_secret.mysql-root[each.key].data.value : ""
      database_user      = each.value.local_resource.mysql_data.user
      database_name      = each.value.local_resource.mysql_data.database_name
      storage_size       = each.value.local_resource.mysql_data.storage_size
      storage_class_name = var.storage_class_name
      name_override      = each.value.resource_name
      architecture       = each.value.local_resource.mysql_data.architecture
      replica_count      = each.value.local_resource.mysql_data.replica_count
      service_port       = each.value.local_resource.mysql_data.service_port
    })
  ]
  provider = helm.helm-main
  depends_on = [
    helm_release.vault_secret_manifests
  ]
}

resource "random_password" "mysql" {
  for_each = local.mysql_resources_gen_pws
  length   = 16
  special  = false
}

resource "vault_generic_secret" "mysql" {
  for_each = local.mysql_resources_gen_pws
  path     = "${each.value.generate_secret_vault_base_path}/${each.key}/password"
  data_json = jsonencode({
    "value" = each.value.local_resource.create_resource_random_password == true ? random_password.mysql[each.key].result : each.value.local_resource.mysql_data.user_password
  })
}

resource "random_password" "mysql-root" {
  for_each = local.mysql_resources_gen_pws
  length   = 16
  special  = false
}

resource "vault_generic_secret" "mysql-root" {
  for_each = local.mysql_resources_gen_pws
  path     = "${each.value.generate_secret_vault_base_path}/${each.key}/root_password"

  data_json = jsonencode({
    "value" = each.value.local_resource.create_resource_random_password == true ? random_password.mysql-root[each.key].result : each.value.local_resource.mysql_data.root_password
  })
}

locals {
  mysql_resources_gen_pws = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if alltrue([stateful_resource.enabled, stateful_resource.resource_type == "mysql", stateful_resource.generate_secret_name == null, stateful_resource.local_resource != null, try(stateful_resource.local_resource.create_resource_random_password, false)]) }
}
