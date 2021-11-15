
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

resource "random_password" "wso2_mysql_root_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "wso2_mysql_root_password" {
  path = "secret/wso2/mysqlrootpw"

  data_json = jsonencode({
    "value" = random_password.wso2_mysql_root_password.result
  })
}

resource "random_password" "wso2_mysql_password" {
  length = 16
  special = false
}

resource "vault_generic_secret" "wso2_mysql_password" {
  path = "secret/wso2/mysqlpw"

  data_json = jsonencode({
    "value" = random_password.wso2_mysql_password.result
  })
}

module "wso2_init" {
  source = "../modules/wso2-init"

  kubeconfig                   = "${var.project_root_path}/admin-gateway.conf"
  namespace                    = var.wso2_namespace
  environment                  = var.environment
  mysql_version                = var.helm_mysql_wso2_version
  wso2_mysql_repo_version      = var.wso2_mysql_repo_version
  db_root_password             = vault_generic_secret.wso2_mysql_root_password.data.value
  db_username                  = var.wso2_mysql_username
  db_password                  = vault_generic_secret.wso2_mysql_password.data.value
  db_name                      = var.wso2_mysql_database
  db_host                      = var.wso2_mysql_host
  efs_subnet_id                = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-wso2"]["id"]
  efs_security_groups          = [data.terraform_remote_state.infrastructure.outputs.sg_id]
  helm_efs_provisioner_version = var.helm_efs_provisioner_version
  region                       = var.region
  efs_storage_class_name       = "efs"

  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
}

module "iskm" {
  source = "../modules/iskm"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = var.wso2_namespace
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore password from
  keystore_password  = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_user            = "root"
  db_password        = vault_generic_secret.wso2_mysql_root_password.data.value
  db_host            = var.wso2_mysql_host
  contact_email      = var.wso2_email
  iskm_fqdn          = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  intgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  extgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  wso2_admin_pw      = vault_generic_secret.wso2_admin_password.data.value

  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
  depends_on = [module.wso2_init]
}

module "iskm-bizops" {
  source = "../modules/iskm"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = "${var.wso2_namespace}-bizops"
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore password from
  keystore_password  = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_user            = "root"
  db_password        = vault_generic_secret.wso2_mysql_root_password.data.value
  db_host            = "mysql-wso2-bizops.${var.wso2_namespace}-bizops.svc.cluster.local"
  contact_email      = var.wso2_email
  iskm_fqdn          = aws_route53_record.iskm-public-private.fqdn
  intgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  extgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  wso2_admin_pw      = vault_generic_secret.wso2_admin_password.data.value
  node_port          = 31143
  iskm_release_name  = "wso2-is-km-bizops"

  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
  depends_on = [helm_release.mysql-bizops]
}

module "intgw" {
  source = "../modules/int-gw"

  kubeconfig              = "${var.project_root_path}/admin-gateway.conf"
  namespace               = var.wso2_namespace
  root_certificate        = tls_self_signed_cert.ca_cert.cert_pem
  root_private_key        = module.wso2_init.root_private_key
  # TODO: workout where to get keystore and JWS password from
  keystore_password       = "wso2carbon"
  jws_password            = "wso2carbon"
  public_domain_name      = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_user                 = "root"
  db_password             = vault_generic_secret.wso2_mysql_root_password.data.value
  db_host                 = var.wso2_mysql_host  
  contact_email           = var.wso2_email
  iskm_fqdn               = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  intgw_fqdn              = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  wso2_admin_pw           = vault_generic_secret.wso2_admin_password.data.value
  efs_storage_class_name  = "efs"
  
  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }

  depends_on = [module.wso2_init]
}

module "extgw" {
  source = "../modules/ext-gw"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = var.wso2_namespace
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore and JWS password from
  keystore_password             = "wso2carbon"
  public_domain_name            = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_user                       = "root"
  db_password                   = vault_generic_secret.wso2_mysql_root_password.data.value
  db_host                       = var.wso2_mysql_host
  contact_email                 = var.wso2_email
  iskm_fqdn                     = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  extgw_fqdn                    = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  service_account_name          = kubernetes_service_account.vault-auth-gateway.metadata[0].name
  vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
  vault_secret_file_name        = "main-wl-config.xml"
  vault_secret_name             = "${var.whitelist_secret_name_prefix}_fsps"
  vault_sim_wl_secret_file_name = "sim-wl-config.xml"
  vault_sim_wl_secret_name      = "${var.whitelist_secret_name_prefix}_sims"
  vault_pm4ml_wl_secret_file_name = "pm4ml-wl-config.xml"
  vault_pm4ml_wl_secret_name      = "${var.whitelist_secret_name_prefix}_pm4mls"
  helm_deployment               = "wso2-is-km"
  wso2_iskm_helm_name           = module.iskm.helm_release_name
  wso2_admin_pw                 = vault_generic_secret.wso2_admin_password.data.value
  efs_storage_class_name        = "efs"

  providers = {
    helm = helm.helm-gateway
    kubernetes = kubernetes.k8s-gateway
    tls = tls.wso2
  }
  depends_on = [module.wso2_init, module.iskm]
}


resource "helm_release" "deploy-gateway-nginx-ingress-controller" {
  name       = "nginx-ingress"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = var.helm_nginx_version
  namespace  = "default"
  wait       = false
  create_namespace = true

  provider = helm.helm-gateway
  values = [
    "${file("${var.project_root_path}/helm/values-nginx.yaml")}"
  ]
}
