resource "helm_release" "mysql" {
  for_each   = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.mysql_data != null}
  name       = each.value.resource_name
  repository = each.value.local_resource.resource_helm_repo
  chart      = each.value.local_resource.resource_helm_chart
  version    = each.value.local_resource.resource_helm_chart_version
  namespace  = each.value.resource_namespace
  create_namespace = true
  values = [
    templatefile("${path.module}/templates/${each.value.local_resource.resource_helm_values_ref}", {
      password            = vault_generic_secret.mysql[each.key].data.value
      root_password       = vault_generic_secret.mysql-root[each.key].data.value
      database_user       = each.value.local_resource.mysql_data.user
      database_name       = each.value.local_resource.mysql_data.database_name
      storage_size        = each.value.local_resource.mysql_data.storage_size
      storage_class_name  = var.storage_class_name
      name_override       = each.value.resource_name
      architecture        = each.value.local_resource.mysql_data.architecture
      replica_count       = each.value.local_resource.mysql_data.replica_count
    })
  ]
  provider = helm.helm-main
}

resource "random_password" "mysql" {
  for_each    = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.mysql_data != null && stateful_resource.local_resource.create_resource_random_password == true}
  length = 16
  special = false
}

resource "vault_generic_secret" "mysql" {
  for_each    = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.mysql_data != null && stateful_resource.vault_credential_paths.pw_data != null}
  path = "${each.value.vault_credential_paths.pw_data.user_password_path_prefix}/${each.key}"

  data_json = jsonencode({
    "value" = each.value.local_resource.create_resource_random_password == true ? random_password.mysql[each.key].result : each.value.local_resource.mysql_data.user_password
  })
}

resource "random_password" "mysql-root" {
  for_each    = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.mysql_data != null && stateful_resource.local_resource.create_resource_random_password == true}
  length = 16
  special = false
}

resource "vault_generic_secret" "mysql-root" {
  for_each    = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.local_resource.mysql_data != null && stateful_resource.vault_credential_paths.pw_data != null}
  path = "${each.value.vault_credential_paths.pw_data.root_password_path_prefix}/${each.key}"

  data_json = jsonencode({
    "value" = each.value.local_resource.create_resource_random_password == true ? random_password.mysql-root[each.key].result : each.value.local_resource.mysql_data.root_password
  })
}