locals {
  bizops_portal_users_with_passwords = [
    for user in var.bizops_portal_users :
    {
      "username" = user.username
      "password" = vault_generic_secret.bizops_portal_user_password[user.username].data.value
      "email" = user.email
    }
  ]
}

resource "random_password" "bizops_portaladmin_password" {
  length = 30
  special = true
  override_special = "_"
}

resource "vault_generic_secret" "bizops_portaladmin_password" {
  path = "secret/mojaloop/bizopsportal/bofportaladmin"
  data_json = jsonencode({
    "value" = random_password.bizops_portaladmin_password.result
  })
}

resource "random_password" "bizops_portal_user_password" {
  for_each = {for user in var.bizops_portal_users: user.username => user}
  length = 30
  special = true
  override_special = "_"
}

resource "vault_generic_secret" "bizops_portal_user_password" {
  for_each = {for user in var.bizops_portal_users: user.username => user}
  path = "secret/mojaloop/bizopsportal/${each.value.username}"
  data_json = jsonencode({
    "value" = random_password.bizops_portal_user_password[each.value.username].result
  })
}


module "bizops-portal-iskm" {
  source    = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/iskm-bizops?ref=v1.0.42"
  iskm_fqdn = "iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  iskm_rest_port = "443"
  user      = "admin"
  password  = data.vault_generic_secret.ws02_admin_password.data.value
  create_service_provider = "y"
  callback_url = "https://${var.bofportal_name}.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}/kratos/self-service/methods/oidc/callback/idp"
  // portal_users = local.bizops_portal_users_with_passwords
  providers = {
    external = external.wso2-automation-iskm-mcm
  }
}

module "bizops-portal-iskm-user-portaladmin" {
  source    = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/iskm-create-user?ref=v1.0.42"
  iskm_fqdn = "iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  iskm_admin_port = "443"
  admin_user      = "admin"
  admin_password  = data.vault_generic_secret.ws02_admin_password.data.value
  account_username = "bofportaladmin"
  account_password = vault_generic_secret.bizops_portaladmin_password.data.value
  account_email = "portaladmin@test.com"
}

module "bizops-portal-iskm-user-portal-users" {
  for_each = {for user in var.bizops_portal_users: user.username => user}
  source    = "git::https://github.com/mojaloop/iac-shared-modules.git//wso2/iskm-create-user?ref=v1.0.42"
  iskm_fqdn = "iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  iskm_admin_port = "443"
  admin_user      = "admin"
  admin_password  = data.vault_generic_secret.ws02_admin_password.data.value
  account_username = each.value.username
  account_password = vault_generic_secret.bizops_portal_user_password[each.value.username].data.value
  account_email = each.value.email
}

resource "kubernetes_job" "assign-admin-role-to-portaladmin" {
  metadata {
    name = "assign-admin-role-to-portaladmin"
    namespace = "mojaloop"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "assign-role"
          image   = "curlimages/curl:7.80.0"
          command = [
            "sh",
            "-c",
            "curl --location --request PUT 'http://keto-write/relation-tuples' --header 'Content-Type: application/json' --data-raw '{\"namespace\": \"role\",\"object\": \"manager\",\"relation\": \"member\",\"subject\": \"${module.bizops-portal-iskm-user-portaladmin.account_userid}\"}'"
          ]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = false
  provider = kubernetes.k8s-gateway
  depends_on = [helm_release.keto]
}

// TODO: The above command should be improved as it creates keto tuples multiple times.
// The following single line script is working with different flavour of grep. But need to fix it with the above docker image as its throwing unknown option '-P' error
// "tuple_exists=`curl --location --request POST 'http://keto-read/check' --header 'Content-Type: application/json' --data-raw '{\"namespace\": \"role\",\"object\": \"ADMIN_ROLE\",\"relation\": \"member\",\"subject\": \"${module.bizops-portal-iskm-user-portaladmin.account_userid}\"}' | grep -oPm1 '(?<=\"allowed\":)[^}]*'`; if [ \"$tuple_exists\" == \"false\" ]; then curl --location --request PUT 'http://keto-write/relation-tuples' --header 'Content-Type: application/json' --data-raw '{\"namespace\": \"role\",\"object\": \"ADMIN_ROLE\",\"relation\": \"member\",\"subject\": \"${module.bizops-portal-iskm-user-portaladmin.account_userid}\"}'; echo \"Assigned Role\"; else echo \"Role already assigned\"; fi"
