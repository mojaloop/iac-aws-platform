
resource "random_password" "wso2_admin_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "wso2_admin_password" {
  path = "secret/wso2/adminpw"

  data_json = jsonencode({
    "value" = random_password.wso2_admin_password.result
  })
}

data "vault_generic_secret" "wso2_db_password" {
  path = "${var.stateful_resources[local.wso2_resource_index].vault_credential_paths.pw_data.user_password_path_prefix}/wso2-db"
}
data "vault_generic_secret" "wso2_root_db_password" {
  path = "${var.stateful_resources[local.wso2_resource_index].vault_credential_paths.pw_data.root_password_path_prefix}/wso2-db"
}
locals {
  wso2_resource_index = index(var.stateful_resources.*.resource_name, "wso2-db")
}
module "wso2_init" {
  source = "../../modules/wso2-init"

  kubeconfig                   = "${var.project_root_path}/admin-gateway.conf"
  namespace                    = kubernetes_namespace.wso2.metadata[0].name
  environment                  = var.environment
  wso2_mysql_repo_version      = var.wso2_mysql_repo_version
  db_root_password             = data.vault_generic_secret.wso2_root_db_password.data.value
  db_host                      = "${var.stateful_resources[local.wso2_resource_index].logical_service_name}.stateful-services.svc.cluster.local"

  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
}

module "iskm" {
  source = "../../modules/iskm"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = kubernetes_namespace.wso2.metadata[0].name
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore password from
  keystore_password  = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_user            = "root"
  db_password        = data.vault_generic_secret.wso2_root_db_password.data.value
  db_host            = "${var.stateful_resources[local.wso2_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
  contact_email      = var.wso2_email
  iskm_fqdn          = "iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  intgw_fqdn         = "intgw-mgmt-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  extgw_fqdn         = "extgw-mgmt-int.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  wso2_admin_pw      = vault_generic_secret.wso2_admin_password.data.value
  int_ingress_controller_name  = "nginx"

  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
  depends_on = [module.wso2_init]
}

module "intgw" {
  source = "../../modules/int-gw"

  kubeconfig              = "${var.project_root_path}/admin-gateway.conf"
  namespace               = kubernetes_namespace.wso2.metadata[0].name
  root_certificate        = module.wso2_init.root_certificate
  root_private_key        = module.wso2_init.root_private_key
  # TODO: workout where to get keystore and JWS password from
  keystore_password       = "wso2carbon"
  jws_password            = "wso2carbon"
  public_domain_name      = data.terraform_remote_state.infrastructure.outputs.public_subdomain
  db_user                 = "root"
  db_password             = data.vault_generic_secret.wso2_root_db_password.data.value
  db_host                 = "${var.stateful_resources[local.wso2_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
  contact_email           = var.wso2_email
  iskm_fqdn               = "iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  wso2_admin_pw           = vault_generic_secret.wso2_admin_password.data.value
  hostname                     = "intgw"
  int_ingress_controller_name  = "nginx"
  
  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }

  depends_on = [module.wso2_init]
}

module "extgw" {
  source = "../../modules/ext-gw"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = kubernetes_namespace.wso2.metadata[0].name
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore and JWS password from
  keystore_password             = "wso2carbon"
  public_domain_name            = data.terraform_remote_state.infrastructure.outputs.public_subdomain
  db_user                       = "root"
  db_password                   = data.vault_generic_secret.wso2_root_db_password.data.value
  db_host                       = "${var.stateful_resources[local.wso2_resource_index].logical_service_name}.stateful-services.svc.cluster.local"
  contact_email                 = var.wso2_email
  iskm_fqdn                     = "iskm.${data.terraform_remote_state.infrastructure.outputs.public_subdomain}"
  service_account_name          = kubernetes_service_account.vault-auth-gateway.metadata[0].name
  vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
  vault_secret_file_name        = "main-wl-config.xml"
  vault_secret_name             = "${var.whitelist_secret_name_prefix}_fsps"
  vault_pm4ml_wl_secret_file_name = "pm4ml-wl-config.xml"
  vault_pm4ml_wl_secret_name      = "${var.whitelist_secret_name_prefix}_pm4mls"
  helm_deployment               = "wso2-is-km"
  wso2_iskm_helm_name           = module.iskm.helm_release_name
  wso2_admin_pw                 = vault_generic_secret.wso2_admin_password.data.value
  data_ext_issuer_name         = kubernetes_manifest.vault-issuer-root.manifest.metadata.name
  hostname                     = "extgw"
  ext_ingress_controller_name  = "nginx-ext"
  int_ingress_controller_name  = "nginx"
  vault-certman-secretname     = var.vault-certman-secretname
  storage_class_name = var.storage_class_name
  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
  depends_on = [module.wso2_init, module.iskm]
}