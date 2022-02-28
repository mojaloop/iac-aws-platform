locals {
  mojaloopRoles = jsondecode(file("${var.project_root_path}/bof-custom-resources/role-permissions/mojaloop-roles.json"))
  permissionExclusions = jsondecode(file("${var.project_root_path}/bof-custom-resources/role-permissions/permission-exclusions.json"))
}

resource "kubernetes_manifest" "bof-roles" {
  for_each = {for role in local.mojaloopRoles: role.rolename => role}
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

resource "kubernetes_manifest" "bof-permission-exclusions" {
  for_each = {for pe in local.permissionExclusions: pe.name => pe}
  manifest = {
    apiVersion = "mojaloop.io/v1"
    kind       = "MojaloopPermissionExclusions"

    metadata = {
      name = lower(replace(each.value.name, "_", "-"))
      namespace = "mojaloop"
    }

    spec = {
      permissionsA = each.value.permissionsA
      permissionsB = each.value.permissionsB 
    }
  }
  provider = kubernetes.k8s-gateway
}