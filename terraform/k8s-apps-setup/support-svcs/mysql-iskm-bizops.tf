/* resource "helm_release" "mysql-bizops" {
  name       = "mysql-wso2-bizops"
  repository = "https://charts.helm.sh/stable"
  chart      = "mysql"
  version    = var.helm_mysql_wso2_version
  namespace  = "${var.wso2_namespace}-bizops"
  create_namespace = true
  set {
    name  = "mysqlRootPassword"
    value = vault_generic_secret.wso2_mysql_root_password.data.value
    type  = "string"
  }

  set {
    name  = "mysqlUser"
    value = var.wso2_mysql_username
    type  = "string"
  }
  set {
    name  = "mysqlPassword"
    value = vault_generic_secret.wso2_mysql_password.data.value
    type  = "string"
  }

  set {
    name  = "mysqlDatabase"
    value = var.wso2_mysql_database
    type  = "string"
  }
  set {
    name  = "persistence.storageClass"
    value = var.ebs_storage_class_name
    type  = "string"
  }

  set {
    name  = "persistence.accessMode"
    value = "ReadWriteOnce"
    type  = "string"
  }
  set {
    name  = "persistence.size"
    value = "8Gi"
    type  = "string"
  }
  provider = helm.helm-main
  depends_on = [module.wso2_init]
}

resource "kubernetes_job" "mysql_ext" {
  metadata {
    name      = "mysql-init-ext"
    namespace = "${var.wso2_namespace}-bizops"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mysql-init-ext"
          image   = "mysql:5.7"
          command = ["/bin/bash", "-c", "apt update && apt install git -y && git clone -b ${var.wso2_mysql_repo_version} https://github.com/mojaloop/wso2-mysql.git && cd wso2-mysql && ./mysql-init.sh -h mysql-wso2-bizops.${var.wso2_namespace}-bizops.svc.cluster.local -u root -p ${vault_generic_secret.wso2_mysql_root_password.data.value} -l ext -r 260 -d y"]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
    #ttl_seconds_after_finished = 60
  }
  provider = kubernetes.k8s-main
  depends_on = [helm_release.mysql-bizops]
}

resource "kubernetes_job" "mysql_int" {
  metadata {
    name      = "mysql-init-int"
    namespace = "${var.wso2_namespace}-bizops"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "mysql-init-int"
          image   = "mysql:5.7"
          command = ["/bin/bash", "-c", "apt update && apt install git -y && git clone -b ${var.wso2_mysql_repo_version} https://github.com/mojaloop/wso2-mysql.git && cd wso2-mysql && ./mysql-init.sh -h mysql-wso2-bizops.${var.wso2_namespace}-bizops.svc.cluster.local -u root -p ${vault_generic_secret.wso2_mysql_root_password.data.value} -l int -r 260 -d y"]
        }
        restart_policy = "Never"
      }
    }
    #ttl_seconds_after_finished = 60
    backoff_limit = 4
  }
  provider = kubernetes.k8s-main
  depends_on = [helm_release.mysql-bizops]
} */