resource "kubernetes_manifest" "bof-roles" {
  for_each = {for role in var.bizops_mojaloop_roles: role.rolename => role}
  manifest = {
    apiVersion = "mojaloop.io/v1"
    kind       = "MojaloopRole"

    metadata = {
      name = lower(replace(each.value.rolename, "_", "-"))
      namespace = "mojaloop"
    }

    spec = {
      role = each.value.rolename
      permissions = each.value.permissions 
    }
  }
  provider = kubernetes.k8s-gateway
}