resource "helm_release" "vault_cr_pwdpolicy" {
  for_each = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.resource_name => stateful_resource}
  name = "vault-cr-pwdpolicy-${each.key}"
  chart = "${path.module}/vault-cr-pwdpolicy"
  create_namespace = false
  values = [templatefile("${path.module}/templates/values-vault-crs.yaml.tpl", {
    auth_svc_acct = "default"
    auth_path = "kubernetes_op"
    auth_role = "policy-admin"
    resource_type = each.value.resource_type
    namespace = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
    secret_password_policy = templatefile("${path.module}/templates/password-policy.hcl.tpl", { password_length = 20, use_special_chars = false, special_char_list = "!@#$%^&*"})
    vault_base_path = each.value.generate_secret_vault_base_path
    resource_name = each.value.resource_name
    secret_name = each.value.generate_secret_name
    secret_keys_map  = { for key in each.value.generate_secret_keys : key => "'{{ .dynamicsecret_${replace(key, "-", "_")}.password }}'" }
    secret_namespaces = "[${join(",", local.total_secret_namespaces[each.key])}]"
  })]
  provider = helm.helm-main
}

resource "helm_release" "vault_cr_randomsecret" {
  for_each = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.resource_name => stateful_resource}
  name = "vault-cr-randomsecret-${each.key}"
  chart = "${path.module}/vault-cr-randomsecret"
  create_namespace = false
  values = [templatefile("${path.module}/templates/values-vault-crs.yaml.tpl", {
    auth_svc_acct = "default"
    auth_path = "kubernetes_op"
    auth_role = "policy-admin"
    resource_type = each.value.resource_type
    namespace = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
    secret_password_policy = templatefile("${path.module}/templates/password-policy.hcl.tpl", { password_length = 20, use_special_chars = false, special_char_list = "!@#$%^&*"})
    vault_base_path = each.value.generate_secret_vault_base_path
    resource_name = each.value.resource_name
    secret_name = each.value.generate_secret_name
    secret_keys_map  = { for key in each.value.generate_secret_keys : key => "'{{ .dynamicsecret_${replace(key, "-", "_")}.password }}'" }
    secret_namespaces = "[${join(",", local.total_secret_namespaces[each.key])}]"
  })]
  provider = helm.helm-main
  depends_on = [
    helm_release.vault_cr_pwdpolicy
  ]
}

resource "helm_release" "vault_cr_vaultsecret" {
  for_each = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.resource_name => stateful_resource}
  name = "vault-cr-vaultsecret-${each.key}"
  chart = "${path.module}/vault-cr-vaultsecret"
  create_namespace = false
  values = [templatefile("${path.module}/templates/values-vault-crs.yaml.tpl", {
    auth_svc_acct = "default"
    auth_path = "kubernetes_op"
    auth_role = "policy-admin"
    resource_type = each.value.resource_type
    namespace = kubernetes_namespace.stateful_namespace[each.value.resource_namespace].metadata[0].name
    secret_password_policy = templatefile("${path.module}/templates/password-policy.hcl.tpl", { password_length = 20, use_special_chars = false, special_char_list = "!@#$%^&*"})
    vault_base_path = each.value.generate_secret_vault_base_path
    resource_name = each.value.resource_name
    secret_name = each.value.generate_secret_name
    secret_keys_map  = { for key in each.value.generate_secret_keys : key => "'{{ .dynamicsecret_${replace(key, "-", "_")}.password }}'" }
    secret_namespaces = "[${join(",", local.total_secret_namespaces[each.key])}]"
  })]
  provider = helm.helm-main
  depends_on = [
    helm_release.vault_cr_randomsecret
  ]
}

locals {
  enabled_stateful_resources = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled && stateful_resource.local_resource != null && stateful_resource.generate_secret_name != null}
  stateful_namespaces = [for stateful_resource in var.stateful_resources : stateful_resource.resource_namespace if stateful_resource.enabled]
  extra_namespaces = [for stateful_resource in var.stateful_resources : stateful_resource.generate_secret_extra_namespaces if stateful_resource.enabled && stateful_resource.generate_secret_extra_namespaces != null]
  total_secret_namespaces = {for stateful_resource in var.stateful_resources : stateful_resource.resource_name => flatten(concat([stateful_resource.resource_namespace], stateful_resource.generate_secret_extra_namespaces != null ? stateful_resource.generate_secret_extra_namespaces : [])) if stateful_resource.enabled && stateful_resource.generate_secret_name != null}
}

resource "kubernetes_namespace" "stateful_namespace" {
  for_each = toset(distinct(concat(local.stateful_namespaces, flatten(local.extra_namespaces))))
  metadata {
    name = each.value
  }
  provider = kubernetes.k8s-main
}
