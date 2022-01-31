#todo, replace with sensitive value
/*resource "random_password" "cookie_secret" {
  length = 32
  special = true
}

 resource "helm_release" "oauth2-proxy" {
  name       = "oauth2-proxy"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  version    = var.helm_oauth2_proxy_version
  namespace  = data.terraform_remote_state.vault.outputs.keycloak_namespace
  timeout    = 300
  values = [
    templatefile("${path.module}/templates/values-oauth2-proxy.yaml.tpl", {
      keycloak_host = "keycloak.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      oauth_host = "oauth.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      keycloak_realm = keycloak_realm.mojaloop-dfsps.realm
      cookie_secret = substr(base64encode(random_password.cookie_secret.result), 0, 32)
      public_subdomain = data.terraform_remote_state.infrastructure.outputs.public_subdomain
      client_id = keycloak_openid_client.openid-dfsp-api-client.client_id
      client_secret = keycloak_openid_client.openid-dfsp-api-client.client_secret
      tls_secret = kubernetes_secret.local-wildcard-secret.metadata[0].name
      keycloak_group = keycloak_group.dfsp-group.name
    })
  ]
  provider = helm.helm-gateway
} */

resource "vault_generic_secret" "keycloak_pw" {
  path = "secret/keycloak/adminpassword"

  data_json = jsonencode({
    "value" = data.terraform_remote_state.vault.outputs.keycloak_secret_key
  })
}

resource "helm_release" "oathkeeper-keycloak" {
  name       = "oathkeeper-keycloak"
  repository = "https://k8s.ory.sh/helm/charts"
  chart      = "oathkeeper"
  version    = "0.21.5"
  namespace  = data.terraform_remote_state.vault.outputs.keycloak_namespace
  timeout    = 150

  values = [  
    templatefile("${path.module}/templates/values-oathkeeper.yaml.tpl", {
      keycloak_host = "keycloak.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
      keycloak_realm = keycloak_realm.mojaloop-dfsps.realm
      keycloak_audience = keycloak_openid_client.openid-dfsp-api-client.client_id
      keycloak_admin_creds = base64encode("${keycloak_openid_client.openid-dfsp-api-client.client_id}:${keycloak_openid_client.openid-dfsp-api-client.client_secret}")
    })
  ]
  provider = helm.helm-gateway
}

resource "keycloak_realm" "mojaloop-dfsps" {
  realm   = "mojaloop-dfsps"
  enabled = true
}

resource "keycloak_openid_client" "openid-dfsp-api-client" {
  realm_id            = keycloak_realm.mojaloop-dfsps.id
  client_id           = "dfsp-api-client"
  name                = "dfsp-api-client"
  enabled             = true
  standard_flow_enabled = true
  access_type         = "PUBLIC"
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "https://*.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}/*"
  ]

  login_theme = "keycloak"
}

resource "keycloak_openid_group_membership_protocol_mapper" "group_membership_mapper" {
  realm_id  = keycloak_realm.mojaloop-dfsps.id
  client_id = keycloak_openid_client.openid-dfsp-api-client.id
  name      = "group-membership-mapper"

  claim_name = "groups"
}

resource "keycloak_openid_audience_protocol_mapper" "audience_mapper" {
  realm_id  = keycloak_realm.mojaloop-dfsps.id
  client_id = keycloak_openid_client.openid-dfsp-api-client.id
  name      = "audience-mapper"

  included_client_audience = keycloak_openid_client.openid-dfsp-api-client.client_id
}

resource "keycloak_group" "dfsp-group" {
  realm_id = keycloak_realm.mojaloop-dfsps.id
  name     = "dfsp"
}

resource "keycloak_user" "dfsp1-user" {
  realm_id = keycloak_realm.mojaloop-dfsps.id
  username = "dfsp1"
}

resource "keycloak_user_groups" "dfsp-user-groups" {
  realm_id = keycloak_realm.mojaloop-dfsps.id
  user_id = keycloak_user.dfsp1-user.id

  group_ids  = [
    keycloak_group.dfsp-group.id
  ]
}