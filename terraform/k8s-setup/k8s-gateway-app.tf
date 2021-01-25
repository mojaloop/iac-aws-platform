
resource "random_password" "ws02_admin_password" {
  length  = 12
  special = false
}

resource "vault_generic_secret" "ws02_admin_password" {
  path = "secret/wso2/adminpw"

  data_json = jsonencode({
    "value" = random_password.ws02_admin_password.result
  })
}

module "wso2_init" {
  source = "../modules/wso2-init"

  kubeconfig                   = "${var.project_root_path}/admin-gateway.conf"
  namespace                    = var.wso2_namespace
  environment                  = var.environment
  mysql_version                = "1.6.1"
  wso2_mysql_repo_version      = var.wso2_mysql_repo_version
  db_root_password             = var.wso2_mysql_root_password
  db_username                  = var.wso2_mysql_username
  db_password                  = var.wso2_mysql_password
  db_name                      = var.wso2_mysql_database
  db_host                      = var.wso2_mysql_host
  efs_subnet_id                = data.terraform_remote_state.tenant.outputs.private_subnet_ids["${var.environment}-wso2"]["id"]
  efs_security_groups          = [data.terraform_remote_state.infrastructure.outputs.sg_id]
  helm_efs_provisioner_version = var.helm_efs_provisioner_version
  region                       = var.region
}

module "iskm" {
  source = "../modules/iskm"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = module.wso2_init.k8s_namespace
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore password from
  keystore_password  = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_password        = var.wso2_mysql_password
  contact_email      = "example@example.com"
  iskm_fqdn          = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  intgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  extgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  wso2_admin_pw      = random_password.ws02_admin_password.result
}

module "intgw" {
  source = "../modules/int-gw"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = module.wso2_init.k8s_namespace
  root_certificate = tls_self_signed_cert.ca_cert.cert_pem
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore and JWS password from
  keystore_password  = "wso2carbon"
  jws_password       = "wso2carbon"
  public_domain_name = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_password        = var.wso2_mysql_password
  contact_email      = "example@example.com"
  iskm_fqdn          = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  intgw_fqdn         = data.terraform_remote_state.infrastructure.outputs.intgw_private_fqdn
  wso2_admin_pw      = random_password.ws02_admin_password.result
}

module "extgw" {
  source = "../modules/ext-gw"

  kubeconfig       = "${var.project_root_path}/admin-gateway.conf"
  namespace        = module.wso2_init.k8s_namespace
  root_certificate = module.wso2_init.root_certificate
  root_private_key = module.wso2_init.root_private_key
  # TODO: workout where to get keystore and JWS password from
  keystore_password             = "wso2carbon"
  public_domain_name            = data.terraform_remote_state.tenant.outputs.public_zone_name
  db_password                   = var.wso2_mysql_password
  contact_email                 = "example@example.com"
  iskm_fqdn                     = data.terraform_remote_state.infrastructure.outputs.iskm_private_fqdn
  extgw_fqdn                    = data.terraform_remote_state.infrastructure.outputs.extgw_public_fqdn
  service_account_name          = kubernetes_service_account.vault-auth-gateway.metadata[0].name
  vault_role_name               = vault_kubernetes_auth_backend_role.kubernetes-gateway.role_name
  vault_secret_file_name        = "main-wl-config.xml"
  vault_secret_name             = "${var.whitelist_secret_name_prefix}_fsp"
  vault_sim_wl_secret_file_name = "sim-wl-config.xml"
  vault_sim_wl_secret_name      = "${var.whitelist_secret_name_prefix}_sims"
  helm_release                  = module.iskm.helm_release
  helm_deployment               = "wso2-is-km"
  wso2_admin_pw                 = random_password.ws02_admin_password.result
}

#monitoring and logging deployments
resource "helm_release" "prometheus-gateway" {
  name         = "prometheus-gateway"
  repository   = "https://charts.helm.sh/stable"
  chart        = "prometheus"
  version      = var.helm_prometheus_version
  namespace    = "monitoring"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-workload-clusters-prometheus.yaml")
  ]
  set {
    name  = "server.ingress.hosts"
    value = "{${data.terraform_remote_state.infrastructure.outputs.prometheus-gateway-private-fqdn}}"
  }
  provider = helm.helm-gateway

  depends_on = [module.wso2_init.storage_class]
}

resource "helm_release" "fluentd-gateway" {
  name         = "fluentd-gateway"
  repository   = "https://kiwigrid.github.io"
  chart        = "fluentd-elasticsearch"
  version      = var.helm_fluentd_version
  namespace    = "logging"
  force_update = true

  values = [
    file("${var.project_root_path}/helm/values-workload-clusters-efk-fluentd.yaml")
  ]
  set {
    name  = "elasticsearch.host"
    value = data.terraform_remote_state.infrastructure.outputs.elasticsearch-services-private-fqdn
  }
  set {
    name  = "elasticsearch.port"
    value = "30000"
  }
  provider = helm.helm-gateway

  depends_on = [helm_release.kafka-support-services]
}
