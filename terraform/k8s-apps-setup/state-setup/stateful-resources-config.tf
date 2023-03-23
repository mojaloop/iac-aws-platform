resource "kubectl_manifest" "vault_password_crs" {
  for_each = { for stateful_resource in local.enabled_stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.local_resource != null }
  yaml_body = templatefile("${path.module}/templates/vault-crs.yaml.tpl", { resource = each.value, auth_svc_acct = "default", auth_path = "kubernetes_op", auth_role = "policy-admin"
  })
  provider = kubectl.k8s-main
}

locals {
  enabled_stateful_resources = { for stateful_resource in var.stateful_resources : stateful_resource.resource_name => stateful_resource if stateful_resource.enabled}
}
